# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/webkit-gtk/webkit-gtk-1.1.15.2.ebuild,v 1.8 2010/01/19 17:25:04 armin76 Exp $

EAPI="2"

inherit autotools flag-o-matic eutils

MY_P="webkit-${PV}"
DESCRIPTION="Open source web browser engine"
HOMEPAGE="http://www.webkitgtk.org/"
SRC_URI="http://www.webkitgtk.org/${MY_P}.tar.gz"

LICENSE="LGPL-2 LGPL-2.1 BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 arm ~ia64 ~ppc sparc ~x86 ~x86-fbsd"
# geoclue
IUSE="coverage debug doc +gstreamer pango ruby +websockets"

# use sqlite, svg by default
RDEPEND="
	dev-libs/libxml2
	dev-libs/libxslt
	media-libs/jpeg
	media-libs/libpng
	x11-libs/cairo

	>=x11-libs/gtk+-2.10
	>=gnome-base/gail-1.8
	>=dev-libs/icu-3.8.1-r1
	>=net-libs/libsoup-2.27.91
	>=dev-db/sqlite-3
	>=app-text/enchant-0.22

	gstreamer? (
		media-libs/gstreamer:0.10
		media-libs/gst-plugins-base:0.10 )
	pango? ( >=x11-libs/pango-1.12 )
	!pango? (
		media-libs/freetype:2
		media-libs/fontconfig )
"
DEPEND="${RDEPEND}
	>=sys-devel/flex-2.5.33
	sys-devel/gettext
	dev-util/gperf
	dev-util/pkgconfig
	dev-util/gtk-doc-am
	doc? ( >=dev-util/gtk-doc-1.10 )"

S="${WORKDIR}/${MY_P}"

src_prepare() {

	# FIXME: Fix unaligned accesses on ARM, IA64 and SPARC
	use sparc && epatch "${FILESDIR}"/${P}-unaligned.patch

	# Make it libtool-1 compatible
	rm -v autotools/lt* autotools/libtool.m4 \
		|| die "removing libtool macros failed"
	# Don't force -O2
	sed -i 's/-O2//g' "${S}"/configure.ac || die "sed failed"
	# Prevent maintainer mode from being triggered during make
	AT_M4DIR=autotools eautoreconf
}

src_configure() {
	# It doesn't compile on alpha without this in LDFLAGS
	use alpha && append-ldflags "-Wl,--no-relax"

	# Sigbuses on SPARC with mcpu
	use sparc && filter-flags "-mcpu=*" "-mtune=*"

	local myconf

	myconf="
		$(use_enable coverage)
		$(use_enable debug)
		$(use_enable gstreamer video)
		$(use_enable ruby)
		$(use_enable websockets web_sockets)
		--enable-filters"

	# USE-flag controlled font backend because upstream default is freetype
	# Remove USE-flag once font-backend becomes pango upstream
	if use pango; then
		ewarn "You have enabled the incomplete pango backend"
		ewarn "Please file any and all bugs *upstream*"
		myconf="${myconf} --with-font-backend=pango"
	else
		myconf="${myconf} --with-font-backend=freetype"
	fi

	econf ${myconf}
}

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
	dodoc WebKit/gtk/{NEWS,ChangeLog} || die "dodoc failed"
}
