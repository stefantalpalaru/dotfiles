# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"

DESCRIPTION="library for registering global keyboard shortcuts in GTK apps"
HOMEPAGE="http://kaizer.se/wiki/keybinder/"
SRC_URI="http://kaizer.se/publicfiles/keybinder/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="lua +python"

DEPEND="lua? ( dev-lang/lua )
	python? ( dev-python/pygtk )
	>=x11-libs/gtk+-2.20
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXrender"
RDEPEND="${DEPEND}"

src_configure() {
	# --enable-lua is broken
	econf $(use lua || echo '--disable-lua') \
		$(use_enable python)
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
}
