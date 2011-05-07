# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="A C++ library that supports a few operations on boolean expression binary trees."
HOMEPAGE="http://perso.b2b2c.ca/sarrazip/dev/boolstuff.html"
SRC_URI="http://perso.b2b2c.ca/sarrazip/dev/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND=""
RDEPEND=""


src_unpack() {
	unpack ${P}.tar.gz
}



src_compile() {
	einfo "Running configure"
	econf || die "econf failed"

	einfo "Building ${P}"
	emake || die "emake failed"
}

src_install () {
	einfo "Running make install"
	emake DESTDIR="${D}" install || die "install failed"                                                                         
}


