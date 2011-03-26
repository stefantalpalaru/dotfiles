# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

WANT_AUTOCONF=latest
WANT_AUTOMAKE=latest

inherit autotools eutils flag-o-matic subversion

DESCRIPTION="realize the collective dream of sleeping computers from all over the internet"
HOMEPAGE="http://electricsheep.org/"
SRC_URI=""
ESVN_REPO_URI="http://electricsheep.svn.sourceforge.net/svnroot/electricsheep/trunk/client/"

IUSE=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="dev-libs/expat
	>=dev-util/pkgconfig-0.9.0
	>=gnome-base/libglade-2.5.0:2.0
	media-video/ffmpeg
	sys-libs/zlib
	>=x11-libs/gtk+-2.7.0:2
	x11-libs/libX11
	x11-proto/xproto"
RDEPEND="${DEPEND}
	app-arch/gzip
	=media-gfx/flam3-9999
	media-video/mplayer
	net-misc/curl
	x11-misc/xdg-utils"

src_prepare() {
	epatch "${FILESDIR}"/${P}-xdg-utils.patch
	eautoreconf
}

src_configure() {
	econf --without-gnome
}

src_install() {
	emake install DESTDIR="${D}" || die "make install failed"

	# install the xscreensaver config file
	insinto /usr/share/xscreensaver/config
	doins ${PN}.xml || die "${PN}.xml failed"
}

