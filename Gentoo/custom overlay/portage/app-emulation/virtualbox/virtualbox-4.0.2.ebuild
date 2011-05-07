# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils fdo-mime flag-o-matic linux-info pax-utils qt4-r2 toolchain-funcs

if [[ ${PV} == "9999" ]] ; then
	# XXX: should finish merging the -9999 ebuild into this one ...
	ESVN_REPO_URI="http://www.virtualbox.org/svn/vbox/trunk"
	inherit linux-mod subversion
else
	MY_P=VirtualBox-${PV}
	SRC_URI="http://download.virtualbox.org/virtualbox/${PV}/${MY_P}.tar.bz2"
	S=${WORKDIR}/${MY_P}_OSE
fi

DESCRIPTION="Software family of powerful x86 virtualization"
HOMEPAGE="http://www.virtualbox.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="additions alsa doc headless java pulseaudio +opengl python +qt4 sdk vboxwebsrv vnc"

RDEPEND="additions? ( ~app-emulation/virtualbox-additions-${PV} )
	!app-emulation/virtualbox-bin
	!app-emulation/virtualbox-ose
	~app-emulation/virtualbox-modules-${PV}
	dev-libs/libIDL
	>=dev-libs/libxslt-1.1.19
	headless? ( x11-libs/libX11 )
	!headless? ( media-libs/libsdl[X,video]
		qt4? ( opengl? ( x11-libs/qt-opengl:4 )
			x11-libs/qt-core:4
			x11-libs/qt-gui:4 )
		opengl? ( media-libs/freeglut
			virtual/opengl )
		x11-libs/libXcursor
		x11-libs/libXt )
	net-misc/curl
	vnc? ( >=net-libs/libvncserver-0.9.7 )"

DEPEND="${RDEPEND}
	alsa? ( >=media-libs/alsa-lib-1.0.13 )
	dev-util/pkgconfig
	doc? ( dev-tex/bera
		dev-texlive/texlive-latex
		dev-texlive/texlive-latexextra
		dev-texlive/texlive-latexrecommended )
	>=dev-lang/yasm-0.6.2
	>=dev-util/kbuild-0.1.5-r1
	!headless? ( x11-libs/libXinerama )
	java? ( virtual/jdk )
	media-libs/libpng
	pulseaudio? ( media-sound/pulseaudio )
	python? ( >=dev-lang/python-2.3[threads] )
	sys-devel/bin86
	sys-devel/dev86
	sys-libs/libcap
	sys-power/iasl
	vboxwebsrv? ( >=net-libs/gsoap-2.7.13 )"


pkg_setup() {
	if ! use headless && ! use qt4 ; then
		einfo "No USE=\"qt4\" selected, this build will not include"
		einfo "any Qt frontend."
	elif use headless && use qt4 ; then
		einfo "You selected USE=\"headless qt4\", defaulting to"
		einfo "USE=\"headless\", this build will not include any X11/Qt frontend."
	fi

	if ! use opengl ; then
		einfo "No USE=\"opengl\" selected, this build will lack"
		einfo "the OpenGL feature."
	fi
	# disable distcc
	if hasq distcc $FEATURES ; then
		export PATH=`echo $PATH | sed 's%/usr/lib/distcc/bin:%%'`
	fi
}

src_prepare() {
	# Remove shipped binaries (kBuild,yasm), see bug #232775
	rm -rf kBuild/bin tools

	# Disable things unused or split into separate ebuilds
	sed -e "s/MY_LIBDIR/$(get_libdir)/" \
		"${FILESDIR}"/${PN}-4-localconfig > LocalConfig.kmk || die

	# unset useless/problematic mesa checks in configure
	epatch "${FILESDIR}/${PN}-4.0.0-mesa-check.patch"

	# makeself is only used to build the installer
	epatch "${FILESDIR}/${PN}-4.0.0-makeself-check.patch"

	# add the --enable-vnc option to configure script (bug #348204)
	epatch "${FILESDIR}/${PN}-4.0.0-vnc.patch"
}

src_configure() {
	local myconf
	use alsa       || myconf+=" --disable-alsa"
	use opengl     || myconf+=" --disable-opengl"
	use pulseaudio || myconf+=" --disable-pulse"
	use python     || myconf+=" --disable-python"
	use java       || myconf+=" --disable-java"
	use doc        || myconf+=" --disable-docs"
	use vboxwebsrv && myconf+=" --enable-webservice"
	use vnc        && myconf+=" --enable-vnc"
	if ! use headless ; then
		use qt4 || myconf+=" --disable-qt4"
	else
		myconf+=" --build-headless --disable-opengl"
	fi
	# not an autoconf script
	./configure \
		--with-gcc="$(tc-getCC)" \
		--with-g++="$(tc-getCXX)" \
		--disable-kmods \
		--disable-dbus \
		${myconf} \
		|| die "configure failed"
}

src_compile() {
	source ./env.sh

	# Force kBuild to respect C[XX]FLAGS and MAKEOPTS (bug #178529)
	# and strip all flags
	#strip-flags

	MAKE="kmk" emake \
		TOOL_GXX32_CC="$(tc-getCC)" TOOL_GXX32_CXX="$(tc-getCXX)" \
		TOOL_GXX64_CC="$(tc-getCC)" TOOL_GXX64_CXX="$(tc-getCXX)" \
		TOOL_GXX32_AS="$(tc-getCC)" TOOL_GXX32_AR="$(tc-getAR)" \
		TOOL_GXX64_AS="$(tc-getCC)" TOOL_GXX64_AR="$(tc-getAR)" \
		TOOL_GXX32_LD="$(tc-getCXX)" TOOL_GXX32_LD_SYSMOD="$(tc-getLD)" \
		TOOL_GXX64_LD="$(tc-getCXX)" TOOL_GXX64_LD_SYSMOD="$(tc-getLD)" \
		VBOX_GCC_OPT="${CFLAGS}" \
		TOOL_YASM_AS=yasm KBUILD_PATH="${S}/kBuild" \
		all || die "kmk failed"
}

src_install() {
	cd "${S}"/out/linux.*/release/bin || die

	# Create configuration files
	insinto /etc/vbox
	newins "${FILESDIR}/${PN}-4-config" vbox.cfg

	# Set the right libdir
	sed -i \
		-e "s/MY_LIBDIR/$(get_libdir)/" \
		"${D}"/etc/vbox/vbox.cfg || die "vbox.cfg sed failed"

	# Symlink binaries to the shipped wrapper
	exeinto /usr/$(get_libdir)/${PN}
	newexe "${FILESDIR}/${PN}-3-wrapper" "VBox" || die
	fowners root:vboxusers /usr/$(get_libdir)/${PN}/VBox
	fperms 0750 /usr/$(get_libdir)/${PN}/VBox

	dosym /usr/$(get_libdir)/${PN}/VBox /usr/bin/VBoxManage
	dosym /usr/$(get_libdir)/${PN}/VBox /usr/bin/VBoxVRDP
	dosym /usr/$(get_libdir)/${PN}/VBox /usr/bin/VBoxHeadless
	dosym /usr/$(get_libdir)/${PN}/VBoxTunctl /usr/bin/VBoxTunctl

	# Install binaries and libraries
	insinto /usr/$(get_libdir)/${PN}
	doins -r components || die

	if use sdk ; then
		doins -r sdk || die
	fi

	if use vboxwebsrv ; then
		doins vboxwebsrv || die
		fowners root:vboxusers /usr/$(get_libdir)/${PN}/vboxwebsrv
		fperms 0750 /usr/$(get_libdir)/${PN}/vboxwebsrv
		dosym /usr/$(get_libdir)/${PN}/VBox /usr/bin/vboxwebsrv
		newinitd "${FILESDIR}"/vboxwebsrv-initd vboxwebsrv
		newconfd "${FILESDIR}"/vboxwebsrv-confd vboxwebsrv
	fi

	for each in VBox{Manage,SVC,XPCOMIPCD,Tunctl,NetAdpCtl,NetDHCP} *so *r0 *gc ; do
		doins $each || die
		fowners root:vboxusers /usr/$(get_libdir)/${PN}/${each}
		fperms 0750 /usr/$(get_libdir)/${PN}/${each}
	done
	# VBoxNetAdpCtl binary needs to be suid root in any case..
	fperms 4750 /usr/$(get_libdir)/${PN}/VBoxNetAdpCtl

	if ! use headless ; then
		for each in VBox{SDL,Headless} ; do
			doins $each || die
			fowners root:vboxusers /usr/$(get_libdir)/${PN}/${each}
			fperms 4750 /usr/$(get_libdir)/${PN}/${each}
			pax-mark -m "${D}"/usr/$(get_libdir)/${PN}/${each}
		done

		if use opengl && use qt4 ; then
			doins VBoxTestOGL || die
			fowners root:vboxusers /usr/$(get_libdir)/${PN}/VBoxTestOGL
			fperms 0750 /usr/$(get_libdir)/${PN}/VBoxTestOGL
		fi

		dosym /usr/$(get_libdir)/${PN}/VBox /usr/bin/VBoxSDL

		if use qt4 ; then
			doins VirtualBox || die
			fowners root:vboxusers /usr/$(get_libdir)/${PN}/VirtualBox
			fperms 4750 /usr/$(get_libdir)/${PN}/VirtualBox
			pax-mark -m "${D}"/usr/$(get_libdir)/${PN}/VirtualBox

			dosym /usr/$(get_libdir)/${PN}/VBox /usr/bin/VirtualBox
		fi

		newicon	"${S}"/src/VBox/Frontends/VirtualBox/images/OSE/VirtualBox_32px.png ${PN}.png
		newmenu "${FILESDIR}"/${PN}.desktop-2 ${PN}.desktop
	else
		doins VBoxHeadless || die
		fowners root:vboxusers /usr/$(get_libdir)/${PN}/VBoxHeadless
		fperms 4750 /usr/$(get_libdir)/${PN}/VBoxHeadless
		pax-mark -m "${D}"/usr/$(get_libdir)/${PN}/VBoxHeadless
	fi

	# Install EFI Firmware files (bug #320757)
	pushd "${S}"/src/VBox/Devices/EFI/FirmwareBin &>/dev/null || die
	for fwfile in VBoxEFI{32,64}.fd ; do
		doins ${fwfile} || die
		fowners root:vboxusers /usr/$(get_libdir)/${PN}/${fwfile} || die
	done
	popd &>/dev/null || die

	insinto /usr/share/${PN}
	if ! use headless && use qt4 ; then
		doins -r nls
	fi

	# set an env-variable for 3rd party tools
	echo -n "VBOX_APP_HOME=/usr/$(get_libdir)/${PN}" > "${T}/90virtualbox"
	doenvd "${T}/90virtualbox"
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	if ! use headless && use qt4 ; then
		elog "To launch VirtualBox just type: \"VirtualBox\""
	fi
	elog "You must be in the vboxusers group to use VirtualBox."
	elog ""
	elog "For advanced networking setups you should emerge:"
	elog "net-misc/bridge-utils and sys-apps/usermode-utilities"
}

pkg_postrm() {
	fdo-mime_desktop_database_update
}
