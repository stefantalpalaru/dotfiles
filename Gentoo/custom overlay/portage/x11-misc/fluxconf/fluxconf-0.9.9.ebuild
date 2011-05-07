# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

IUSE="gtk2"

DESCRIPTION="Configuration editor for fluxbox"
SRC_URI="http://devaux.fabien.free.fr/flux/${P}.tar.gz"
HOMEPAGE="http://devaux.fabien.free.fr/flux/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"

RDEPEND="!gtk2? ( =x11-libs/gtk+-1.2* )
	gtk2? ( >=x11-libs/gtk+-2.0.0 )
	x11-wm/fluxbox"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

pkg_setup() {
	if ! use gtk2 ; then
		if has_version ">=x11-libs/gtk+-2.0.0" ; then
			einfo ""
			einfo "GTK2 found, fluxconf will be compiled with GTK2"
			einfo "support regardless of the USE-flag setting. No way"
			einfo "to change that behaviour, sorry."
			einfo ""
			epause 2
		else
			einfo ""
			einfo "The fluxmenu program will not function properly, if"
			einfo "at all, if compiled with GTK1 support only (See README)."
			einfo "Please consider re-emerging with USE='gtk2'."
			einfo ""
			epause 2
		fi
	fi
}

src_install() {
	einstall || die
	rm "${D}/usr/bin/fluxkeys" "${D}/usr/bin/fluxmenu"

	dosym /usr/bin/fluxconf /usr/bin/fluxkeys
	dosym /usr/bin/fluxconf /usr/bin/fluxmenu
	dosym /usr/bin/fluxconf /usr/bin/fluxbare

	dodoc AUTHORS ChangeLog NEWS README TODO
}
