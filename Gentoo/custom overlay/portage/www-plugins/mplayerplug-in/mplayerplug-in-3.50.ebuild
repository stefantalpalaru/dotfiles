# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-plugins/mplayerplug-in/mplayerplug-in-3.50.ebuild,v 1.2 2009/05/29 21:04:47 beandog Exp $

inherit eutils multilib autotools

DESCRIPTION="mplayer plug-in for Gecko based browsers"
HOMEPAGE="http://mplayerplug-in.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 -hppa ~ia64 ppc ppc64 sparc x86"
IUSE="gtk divx firefox gmedia nls quicktime realmedia seamonkey wmp xulrunner"

LANGS="cs da de en_US es fr hu it ja ko nb nl pl pt_BR ru sk se tr wa zh_CN"
for X in ${LANGS}; do IUSE="${IUSE} linguas_${X}"; done

RDEPEND=">=media-video/mplayer-1.0_pre5
		xulrunner? ( =net-libs/xulrunner-1.8* )
		!xulrunner? ( firefox? ( =www-client/mozilla-firefox-2* ) )
		!xulrunner? ( !firefox? ( seamonkey? ( =www-client/seamonkey-1* ) ) )
		x11-libs/libXpm
		x11-proto/xextproto
		gtk? (
			>=x11-libs/gtk+-2.2.0
			dev-libs/atk
			>=dev-libs/glib-2.2.0
			>=x11-libs/pango-1.2.1
		)"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${PN}-3.40-cflags.patch"
	epatch "${FILESDIR}/${PN}-gcc4.patch"
	epatch "${FILESDIR}/${PN}_xulrunner-1.9.patch"
	epatch "${FILESDIR}/${P}-seamonkey.patch"
	eautoconf
}

src_compile() {
	local myconf

	# We force gtk2 now because moz only compiles against gtk2
	if use gtk; then
		myconf="${myconf} --enable-gtk2"
	else
		ewarn "For playback controls, you must enable gtk support."
		myconf="${myconf} --enable-x"
	fi

	# Media Playback Support (bug #145517)
	econf \
		${myconf} \
		$(use_enable divx dvx) \
		$(use_enable gmedia gmp) \
		$(use_enable realmedia rm) \
		$(use_enable quicktime qt) \
		$(use_enable wmp) \
		|| die "econf failed"

	emake || die "emake failed"
}

src_install() {
	PLUGINS="in in-gmp in-rm in-qt in-wmp in-dvx"
	plugindir="nsbrowser/plugins"

	exeinto /usr/$(get_libdir)/${plugindir}
	insinto /usr/$(get_libdir)/${plugindir}

	for plugin in ${PLUGINS}; do
		if [ -e "mplayerplug-${plugin}.so" ]; then
			doexe "mplayerplug-${plugin}.so" || die "plugin mplayerplug-${plugin} failed"
		    doins "mplayerplug-${plugin}.xpt" || die "plugin mplayerplug-${plugin} xpt failed"
		fi
	done

	if use nls; then
		local WANT_LANGS
		for X in ${LANGS}; do
			if use linguas_${X}; then
				WANT_LANGS="${WANT_LANGS} ${X}"
			fi
		done
		emake -C po LANGUAGES="${WANT_LANGS# }" DESTDIR="${D}" install \
			|| die "Translation installation failed"
	fi

	insinto /etc
	doins mplayerplug-in.conf

	dodoc ChangeLog INSTALL README DOCS/tech/*.txt
}
