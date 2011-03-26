# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/webkit-gtk/webkit-gtk-0_p40220-r1.ebuild,v 1.5 2009/09/12 22:42:02 eva Exp $

inherit autotools flag-o-matic eutils

MY_P="WebKit-r${PV/0\_p}"
DESCRIPTION="Open source web browser engine"
HOMEPAGE="http://www.webkit.org/"
SRC_URI="http://nightly.webkit.org/files/trunk/src/${MY_P}.tar.bz2"

LICENSE="LGPL-2 LGPL-2.1 BSD"
SLOT="0"
KEYWORDS="alpha amd64 -ia64 ppc -sparc x86 ~x86-fbsd"
IUSE="coverage debug gstreamer pango soup sqlite svg xslt"

RDEPEND=">=x11-libs/gtk+-2.8
	>=dev-libs/icu-3.8.1-r1
	>=net-misc/curl-7.15
	media-libs/jpeg
	media-libs/libpng
	dev-libs/libxml2
	sqlite? ( >=dev-db/sqlite-3 )
	gstreamer? (
		>=media-libs/gst-plugins-base-0.10
		)
	soup? ( >=net-libs/libsoup-2.23.1 )
	xslt? ( dev-libs/libxslt )
	pango? ( x11-libs/pango )"

DEPEND="${RDEPEND}
	dev-util/gperf
	dev-util/pkgconfig
	virtual/perl-Text-Balanced"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-gcc44-aliasing.patch"
	epatch "${FILESDIR}/${PN}-CVE-2009-0945.patch"
	eautoreconf
}

src_compile() {
	# It doesn't compile on alpha without this LDFLAGS
	use alpha && append-ldflags "-Wl,--no-relax"

	local myconf
		use pango && myconf="${myconf} --with-font-backend=pango"
		use soup && myconf="${myconf} --with-http-backend=soup"

	econf \
		$(use_enable sqlite database) \
		$(use_enable sqlite icon-database) \
		$(use_enable sqlite dom-storage) \
		$(use_enable sqlite offline-web-applications) \
		$(use_enable gstreamer video) \
		$(use_enable svg) \
		$(use_enable debug) \
		$(use_enable xslt) \
		$(use_enable coverage) \
		${myconf}

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
}

pkg_postinst() {
	if use gstreamer; then
	    ewarn
	    ewarn "If ${PN} doesn't play some video format, please check your"
	    ewarn "USE flags on media-plugins/gst-plugins-meta"
	fi
}
