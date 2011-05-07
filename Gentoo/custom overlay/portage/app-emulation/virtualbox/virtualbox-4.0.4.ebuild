# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils fdo-mime flag-o-matic linux-info pax-utils qt4-r2 toolchain-funcs java-pkg-opt-2

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
	java? ( >=virtual/jdk-1.5 )
	media-libs/libpng
	pulseaudio? ( media-sound/pulseaudio )
	python? ( >=dev-lang/python-2.3[threads] )
	sys-devel/bin86
	sys-devel/dev86
	sys-libs/libcap
	sys-power/iasl
	vboxwebsrv? ( >=net-libs/gsoap-2.7.13 )"

REQUIRED_USE="java? ( sdk ) python? ( sdk )"

pkg_setup() {
	if built_with_use sys-devel/gcc hardened && gcc-config -c | grep -qv -E "hardenednopie|vanilla"; then
		eerror "The PIE feature provided by the \"hardened\" compiler is incompatible with ${PF}."
		eerror "You must use gcc-config to select a profile without this feature.  You may"
		eerror "choose either \"hardenednopie\", \"hardenednopiessp\" or \"vanilla\" profile;"
		eerror "however, \"hardenednopie\" is preferred because it gives the most hardening."
		eerror "Remember to run \"source /etc/profile\" before continuing.  See bug #339914."
		die
	fi

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
	if use java; then
		java-pkg-opt-2_pkg_setup
	fi
}

src_prepare() {
	# Remove shipped binaries (kBuild,yasm), see bug #232775
	rm -rf kBuild/bin tools

	# Disable things unused or split into separate ebuilds
	sed -e "s/MY_LIBDIR/$(get_libdir)/" \
		"${FILESDIR}"/${PN}-4-localconfig > LocalConfig.kmk || die

	# unset useless/problematic checks in configure
	epatch "${FILESDIR}/${PN}-4.0.0-mesa-check.patch"
	epatch "${FILESDIR}/${PN}-4-makeself-check.patch"
	epatch "${FILESDIR}/${PN}-4-mkisofs-check.patch"

	# fix build with --as-needed (bug #249295 and bug #350907)
	epatch "${FILESDIR}/${PN}-4-asneeded.patch"

	# Respect LDFLAGS
	sed -e "s/_LDFLAGS\.${ARCH}*.*=/& ${LDFLAGS}/g" \
		-i Config.kmk src/libs/xpcom18a4/Config.kmk || die

	# We still want to use ${HOME}/.VirtualBox/Machines as machines dir.
	epatch "${FILESDIR}/${PN}-4.0.2-restore_old_machines_dir.patch"

	# add the --enable-vnc option to configure script (bug #348204)
	epatch "${FILESDIR}/${PN}-4.0.0-vnc.patch"

	# add correct java path
	if use java ; then
		sed "s:/usr/lib/jvm/java-6-sun:$(java-config -O):" \
			-i "${S}"/Config.kmk || die
		java-pkg-opt-2_src_prepare
	fi
}

src_configure() {
	local myconf
	use alsa       || myconf+=" --disable-alsa"
	use opengl     || myconf+=" --disable-opengl"
	use pulseaudio || myconf+=" --disable-pulse"
	use python     || myconf+=" --disable-python"
	use java       || myconf+=" --disable-java"
	use vboxwebsrv && myconf+=" --enable-webservice"
	use vnc        && myconf+=" --enable-vnc"
	use doc        || myconf+=" --disable-docs"
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

	MAKE="kmk" emake KBUILD_VERBOSE=2 \
		TOOL_GCC3_CC="$(tc-getCC)" TOOL_GCC3_CXX="$(tc-getCXX)" \
		TOOL_GCC3_AS="$(tc-getCC)" TOOL_GCC3_AR="$(tc-getAR)" \
		TOOL_GCC3_LD="$(tc-getCXX)" TOOL_GCC3_LD_SYSMOD="$(tc-getLD)" \
		TOOL_GCC3_CFLAGS="${CFLAGS}" TOOL_GCC3_CXXFLAGS="${CXXFLAGS}" \
		VBOX_GCC_OPT="${CFLAGS}" VBOX_GCC_R0_OPT="${CFLAGS}" VBOX_GCC_GC_OPT="${CFLAGS}"  \
		TOOL_YASM_AS=yasm KBUILD_PATH="${S}/kBuild" \
		all || die "kmk failed"
}

src_install() {
	cd "${S}"/out/linux.${ARCH}/release/bin || die

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
