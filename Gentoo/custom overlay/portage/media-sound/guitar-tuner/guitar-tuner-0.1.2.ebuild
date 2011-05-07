# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Gtk2 Guitar Tuner."

HOMEPAGE="http://bertozlabs.awardspace.biz/"
SRC_URI="http://bertozlabs.awardspace.biz/Projects/${PN}/files/${P}.tar.bz2"

SLOT="0"
KEYWORDS="~x86"
IUSE=""
LICENSE="GPL-2"

DEPEND=">=x11-libs/gtk+-2.8.0
		>=sci-libs/fftw-3.1"
RDEPEND="${DEPEND}"

src_compile() {
	cd ${WORKDIR}/${PN}
	econf || die "Error: econf failed!"
	emake || die "Error: emake failed!"
}

src_install() {
	cd ${WORKDIR}/${PN}
	einstall || die "Error: einstall failed!"
}

pkg_postinst() {
	einfo
	einfo "${PN} Infos"
	einfo "http://bertozlabs.awardspace.biz/Projects/${PN}.php"
	einfo
}
