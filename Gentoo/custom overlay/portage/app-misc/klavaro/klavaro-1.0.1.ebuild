# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Klavaro is just another free touch typing tutor program."
HOMEPAGE="http://klavaro.sourceforge.net/"
SRC_URI="mirror://sourceforge/klavaro/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~sparc ~x86"
IUSE=""

DEPEND=">=x11-libs/gtk+-2"
RDEPEND="${DEPEND}"

src_install() {
	make DESTDIR=${D} install || die
	make_desktop_entry klavaro Klavaro "" Education
	dodoc AUTHORS ChangeLog NEWS README
}
