# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit git eutils qt4

DESCRIPTION="Heimdall is a cross-platform open-source tool suite used to flash firmware (aka ROMs) onto Samsung Galaxy S devices."
HOMEPAGE="http://www.glassechidna.com.au/products/heimdall/"

EGIT_REPO_URI="git://github.com/Benjamin-Dobell/Heimdall.git"
EGIT_TREE="master"
EGIT_PROJECT="Heimdall"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"

IUSE="qt4"

RDEPEND="qt4? ( >=x11-libs/qt-gui-4.6 )
    >dev-libs/libusb-1.0
    dev-util/pkgconfig"

DEPEND="$RDEPEND"

src_unpack() {
	git_src_unpack
}

src_prepare() {
	sed -e 's:/usr/local:/usr:g' -i "${S}"/${PN}-frontend/${PN}-frontend.pro \
		|| die
	sed 's:SYSFS:ATTRS:g' -i "${S}"/${PN}/60-${PN}-galaxy-s.rules || die
}

src_configure() {
	cd "${S}"/${PN} || die
	econf --prefix=/usr/ --libdir=/usr/$(get_libdir) || die "econf failed"
	if use qt4 ; then
		cd "${S}"/${PN}-frontend || die
		eqmake4 ${PN}-frontend.pro
	fi
}

src_compile() {
	cd "${S}"/${PN} || die
	emake DESTDIR="${D}" || die "compile failed"
	if use qt4 ; then
		cd "${S}"/${PN}-frontend || die
		emake || die "compile failed"
	fi
}

src_install() {
	cd "${S}"/${PN} || die
	sed -e '/sudo service udev restart/d' -i Makefile \
		|| die "Couldn't patch Makefile"
	emake DESTDIR="${D}" install || die "install failed"
	if use qt4 ; then
		cd "${S}"/${PN}-frontend || die
		emake INSTALL_ROOT="${D}" install || die "compile failed"
	fi
}

pkg_postinst() {
	udevadm control --reload-rules && udevadm trigger --subsystem-match=usb
}
