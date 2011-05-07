# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#first test on 28/04/08 with default autotools
WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"

inherit autotools

#Required Variables
DESCRIPTION="Lightweight OpenGL-based GUI toolkit used by makehuman"
HOMEPAGE="http://www.dedalo-3d.com/"
SRC_URI="mirror://sourceforge/makehuman/${P}.tar.gz"
SLOT="0"
LICENCE="GPL-1"
KEYWORDS="~x86 ~amd64"
IUSE=""

#Optionnal variables
RDEPEND="
	>=media-libs/libpng-1.2.26-r1
	>=virtual/glut-1.0
	>=media-gfx/animorph-0.3
	"
DEPEND="${RDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}" ;
	#Relocate documentation
	#src_compile fails when using eautoreconf, so modify Makefile.in instead of Makefile.am
	sed -i -e "s/doc\/${PN}/share\/doc\/${P}/g" Makefile.in
}

src_compile() {
	#X required by glut, adding --with-gnu-ld and   --with-pic because we skipped eautoreconf
	econf --with-gnu-ld --with-x || die "econf failed!"
	emake || die "emake failed"
}

src_test() {
	emake check ;
}

src_install() {
	emake DESTDIR=${D} install || die "Make install failed"
}
