# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#first test on 28/04/08 with default autotools
WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"

inherit autotools eutils

#Local variable
MY_P="${PN}-0.9.1-rc1a"

#Required Variables
DESCRIPTION="MakeHuman is a software for the modelling of 3-Dimensional characters"
HOMEPAGE="http://www.dedalo-3d.com/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"
SLOT="0"
LICENCE="GPL-1"
KEYWORDS="~x86 ~amd64"
IUSE=""

#Optionnal variables
RDEPEND="
	>=media-gfx/aqsis-1.2.0
	"
DEPEND="
	${RDEPEND}
	>=media-libs/libpng-1.2.26-r1
	>=virtual/glut-1.0
	>=media-gfx/animorph-0.3
	>=media-gfx/mhgui-0.2
	"

S="$WORKDIR/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}" ;
	#Relocate documentation
	#src_compile fails when using eautoreconf, so modify Makefile.in instead of	Makefile.am
	sed -i -e "s/doc\/${PN}/share\/doc\/${P}/g" Makefile.in
}

src_compile() {
	#X required by glut, adding --with-gnu-ld because we skipped eautoreconf
	econf --with-gnu-ld --with-x || die "econf failed!"
	emake || die "emake failed"
}

src_test() {
	emake check ;
}

src_install() {
	emake DESTDIR=${D} install || die "Make install failed"
	#no png icon
	make_desktop_entry /usr/bin/${PN} Makehuman makehuman.ico Graphics
}

#pkg_postinst() {
#	elog "You may install aqsis or pixie to test rendenring in makehuman"
#}
