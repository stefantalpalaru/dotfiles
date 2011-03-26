# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libtorrent/libtorrent-0.11.9.ebuild,v 1.3 2008/01/10 08:48:45 gmsoft Exp $

inherit eutils toolchain-funcs flag-o-matic libtool

DESCRIPTION="LibTorrent is a BitTorrent library written in C++ for *nix."
HOMEPAGE="http://libtorrent.rakshasa.no/"
SRC_URI="http://libtorrent.rakshasa.no/downloads/${P}.tar.gz"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"

IUSE="debug"

RDEPEND=">=dev-libs/libsigc++-2"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.11"

src_compile() {
	replace-flags -Os -O2

	if [[ $(tc-arch) = "x86" ]]; then
		filter-flags -fomit-frame-pointer -fforce-addr
	fi

	elibtoolize
	econf \
		$(use_enable debug) \
		--enable-static \
		--enable-shared \
		--disable-dependency-tracking \
		|| die "econf failed"

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README TODO
}
