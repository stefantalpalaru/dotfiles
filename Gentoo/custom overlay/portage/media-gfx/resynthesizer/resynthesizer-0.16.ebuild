# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="GIMP plug-in for generating textures within an image"
HOMEPAGE="http://www.logarithmic.net/pfh/resynthesizer"
SRC_URI="http://www.logarithmic.net/pfh-files/resynthesizer/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEPEND=">=media-gfx/gimp-2.2.17"

src_install() {
	exeinto `gimptool-2.0 --gimpplugindir`/plug-ins
	doexe resynth || die "Resynth installation failed"

	insinto `gimptool-2.0 --gimpdatadir`/scripts
	doins smart-enlarge.scm || die "Installation of smart-enlarge.scm failed"
	doins smart-remove.scm || die "Installation of smart-remove.scm failed"
	dodoc README
}

pkg_postinst() {
	elog
	einfo "After restarting the Gimp you should find the"
	einfo "following items in the pop-up image menu:"
	elog 
	einfo "Filters -> Map -> Resynthesize"
	einfo "Filters -> Enhance -> Smart enlarge"
	einfo "Filters -> Enhance -> Smart sharpen"
	einfo "Filters -> Enhance -> Smart remove selection"
	elog
}
