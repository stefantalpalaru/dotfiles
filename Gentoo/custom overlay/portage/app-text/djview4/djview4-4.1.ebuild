# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils nsplugins

DESCRIPTION="portable DjVu viewer and browser plugin using Qt4"
HOMEPAGE="http://djvu.sourceforge.net/djview4.html"
SRC_URI="mirror://sourceforge/djvu/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="nsplugin debug"
DEPEND=">=app-text/djvu-3.5.18 >=x11-libs/qt-4"
RDEPEND="${DEPEND}"
S="${WORKDIR}/${P}.orig"

src_compile() {
	QTDIR=/usr econf $(use_enable debug) --disable-nsdejavu \
		$(built_with_use -a app-text/djvu qt3 nsplugin || use_enable nsplugin nsdejavu) \
		|| die "econf failed"

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" plugindir=/usr/$(get_libdir)/${PLUGINS_DIR} install \
		|| die "emake install failed"
	#remove conflicting symlinks
	built_with_use app-text/djvu qt3 && rm -f "${D}/usr/bin/djview" "${D}/usr/share/man/man1/djview.1"

	dodoc README TODO NEWS
	
	cd desktopfiles
	insinto /usr/share/icons/hicolor/32x32/apps && newins hi32-djview4.png djvulibre-djview4.png
	domenu djvulibre-djview4.desktop
}
