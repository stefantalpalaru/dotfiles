# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils linux-mod

MY_P=VirtualBox-${PV}
DESCRIPTION="VirtualBox kernel modules and user-space tools for Linux guests"
HOMEPAGE="http://www.virtualbox.org/"
SRC_URI="http://download.virtualbox.org/virtualbox/${PV}/${MY_P}.tar.bz2"
S=${WORKDIR}/${MY_P}_OSE

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="X"

RDEPEND="X? ( ~x11-drivers/xf86-video-virtualbox-${PV}
			 ~x11-drivers/xf86-input-virtualbox-${PV}
			 x11-apps/xrandr
			 x11-apps/xrefresh
			 x11-libs/libXmu
			 x11-libs/libX11
			 x11-libs/libXt
			 x11-libs/libXext
			 x11-libs/libXau
			 x11-libs/libXdmcp
			 x11-libs/libSM
			 x11-libs/libICE )"
DEPEND="${RDEPEND}
		>=dev-util/kbuild-0.1.5-r1
		>=dev-lang/yasm-0.6.2
		sys-devel/bin86
		sys-devel/dev86
		sys-libs/pam
		sys-power/iasl
		X? ( x11-proto/renderproto )
		!X? ( x11-proto/xproto )"

BUILD_TARGETS="all"
BUILD_TARGET_ARCH="${ARCH}"
MODULE_NAMES="vboxguest(misc:${WORKDIR}/vboxguest:${WORKDIR}/vboxguest)
			vboxsf(misc:${WORKDIR}/vboxsf:${WORKDIR}/vboxsf)"


pkg_setup() {
		linux-mod_pkg_setup
		BUILD_PARAMS="KERN_DIR=${KV_DIR} KERNOUT=${KV_OUT_DIR}"
		enewgroup vboxguest
		enewuser vboxguest -1 /bin/sh /var/run/vboxguest vboxguest
}

src_unpack() {
		unpack ${A}

		# Create and unpack a tarball with the sources of the Linux guest
		# kernel modules, to include all the needed files
		"${MY_P}_OSE"/src/VBox/Additions/linux/export_modules "${WORKDIR}/vbox-kmod.tar.gz"
		unpack ./vbox-kmod.tar.gz

		# PaX fixes (see bug #298988)
		epatch "${FILESDIR}"/vboxguest-log-use-c99.patch

		# Remove shipped binaries (kBuild,yasm), see bug #232775
		cd "${S}"
		rm -rf kBuild/bin tools

		# Disable things unused or splitted into separate ebuilds
		cp "${FILESDIR}/${PN}-3-localconfig" LocalConfig.kmk

		# stupid new header references...
		for vboxheader in {product,revision}-generated.h ; do
			for mdir in vbox{guest,sf} ; do
				ln -sf "${S}"/out/linux.${ARCH}/release/${vboxheader} \
					"${WORKDIR}/${mdir}/${vboxheader}"
			done
		done
}

src_compile() {
		# build the user-space tools, warnings are harmless
		./configure --nofatal \
		--disable-xpcom \
		--disable-sdl-ttf \
		--disable-pulse \
		--disable-alsa \
		--build-headless || die "configure failed"
		source ./env.sh

		for each in	/src/VBox/{Runtime,Additions/common} \
		/src/VBox/Additions/linux/{sharedfolders,daemon} ; do
				cd "${S}"${each}
				MAKE="kmk" emake TOOL_YASM_AS=yasm \
				KBUILD_PATH="${S}/kBuild" \
				|| die "kmk VBoxControl failed"
		done

		if use X; then
				cd "${S}"/src/VBox/Additions/x11/VBoxClient
				MAKE="kmk" emake TOOL_YASM_AS=yasm \
				KBUILD_PATH="${S}/kBuild" \
				|| die "kmk VBoxClient failed"
		fi

		# Now creating the kernel modules. We must do this _after_
		# we compiled the user-space tools as we need two of the
		# automatically generated header files. (>=3.2.0)
		linux-mod_src_compile
}

src_install() {
		linux-mod_src_install

		cd "${S}"/out/linux.${ARCH}/release/bin/additions

		insinto /sbin
		newins mount.vboxsf mount.vboxsf
		fperms 4755 /sbin/mount.vboxsf

		newinitd "${FILESDIR}"/${PN}-7.initd ${PN}

		insinto /usr/sbin/
		newins VBoxService vboxguest-service
		fperms 0755 /usr/sbin/vboxguest-service

		insinto /usr/bin
		doins VBoxControl
		fperms 0755 /usr/bin/VBoxControl

		# VBoxClient user service and xrandr wrapper
		if use X; then
			doins VBoxClient
			fperms 0755 /usr/bin/VBoxClient

			cd "${S}"/src/VBox/Additions/x11/Installer
			newins 98vboxadd-xclient VBoxClient-all
			fperms 0755 /usr/bin/VBoxClient-all
		fi

		# udev rule for vboxdrv
		dodir /etc/udev/rules.d
		echo 'KERNEL=="vboxguest", OWNER="vboxguest", GROUP="vboxguest", MODE="0660"' \
		>> "${D}/etc/udev/rules.d/60-virtualbox-guest-additions.rules"
		echo 'KERNEL=="vboxuser", OWNER="vboxguest", GROUP="vboxguest", MODE="0660"' \
		>> "${D}/etc/udev/rules.d/60-virtualbox-guest-additions.rules"

		# VBoxClient autostart file
		insinto /etc/xdg/autostart
		doins "${FILESDIR}"/vboxclient.desktop

		# sample xorg.conf
		insinto /usr/share/doc/${PF}
		doins "${FILESDIR}"/xorg.conf.vbox
}

pkg_postinst() {
		linux-mod_pkg_postinst
		if ! useq X ; then
			elog "use flag X is off, enable it to install the"
			elog "X Window System input and video drivers"
		fi
		elog ""
		elog "Please add users to the \"vboxusers\" group so they can"
		elog "benefit from seamless mode, auto-resize and clipboard."
		elog ""
		elog "Please add:"
		elog "/etc/init.d/${PN}"
		elog "to the default runlevel in order to start"
		elog "needed services."
		elog "To use the VirtualBox X drivers, use the following"
		elog "file as your /etc/X11/xorg.conf:"
		elog "    /usr/share/doc/${PF}/xorg.conf.xorg"
		elog ""
		elog "Also make sure you use the Mesa library for OpenGL:"
		elog "    eselect opengl set xorg-x11"
		elog ""
		elog "An autostart .desktop file has been installed to start"
		elog "VBoxClient in desktop sessions."
		elog ""
		elog "You can mount shared folders with:"
		elog "    mount -t vboxsf <shared_folder_name> <mount_point>"
		elog ""
		elog "Warning:"
		elog "this ebuild is only needed if you are running gentoo"
		elog "inside a VirtualBox Virtual Machine, you don't need"
		elog "it to run VirtualBox itself."
		elog ""
}
