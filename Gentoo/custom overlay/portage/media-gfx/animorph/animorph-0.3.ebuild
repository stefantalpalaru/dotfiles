# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#first test  on 28/04/08 with default autotools
WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"

inherit autotools

#Required Variables
DESCRIPTION="Animorph is a 3D processing library used by Makehuman"
HOMEPAGE="http://www.dedalo-3d.com/"
SRC_URI="mirror://sourceforge/makehuman/${P}.tar.gz"
SLOT="0"
LICENCE="GPL-1"
KEYWORDS="~x86 ~amd64"
IUSE=""

#Optionnal variables
RDEPEND=""
DEPEND="${RDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}" ;
	#Relocate documentation
	sed -i -e "s/doc\/${PN}/share\/doc\/${P}/g" Makefile.am
	einfo "Regenerating autotools files..."
	eautoreconf || die "eautoreconf failed"
}

src_compile() {
	econf || die "econf failed!"
	emake || die "emake failed"
}

src_test() {
	emake check ;
}

src_install() {
	emake DESTDIR=${D} install || die "Make install failed"
}
