# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

MY_P="photoprint-0.4.2-pre1"

DESCRIPTION="A utility for printing photos with advanced arrangement capabilities"
HOMEPAGE="http://blackfiveimaging.co.uk/index.php?article=02Software%2F01PhotoPrint"
SRC_URI="http://www.blackfiveimaging.co.uk/photoprint/${MY_P}.tar.gz"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="( >=x11-libs/gtk+-2.4
	>=net-print/gutenprint-5.1.7
	media-libs/lcms
	>=media-libs/netpbm-10.43
	virtual/jpeg
	media-libs/tiff )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"
}

src_install() {
	make install DESTDIR="${D}" || die "make install failed"
}

