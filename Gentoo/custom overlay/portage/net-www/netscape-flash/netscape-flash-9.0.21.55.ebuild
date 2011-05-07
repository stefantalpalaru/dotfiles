# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-www/netscape-flash/netscape-flash-7.0.68.ebuild,v 1.3 2006/09/30 19:55:17 dang Exp $

inherit nsplugins

S=${WORKDIR}/flash-player-plugin-${PV}
DESCRIPTION="Macromedia Shockwave Flash Player"
SRC_URI="mirror://macromedia/rpmsource/FP9_plugin_beta_101806.tar.gz"
HOMEPAGE="http://www.macromedia.com/"

IUSE=""
SLOT="0"
KEYWORDS="amd64 -ppc -sparc x86"
LICENSE="Macromedia"

DEPEND="!net-www/gplflash
	amd64? ( app-emulation/emul-linux-x86-baselibs
			 app-emulation/emul-linux-x86-xlibs )"

RESTRICT="nostrip"

QA_TEXTRELS="opt/netscape/plugins/libflashplayer.so"

pkg_setup() {
	# This is a binary x86 package => ABI=x86
	# Please keep this in future versions
	# Danny van Dyk <kugelfang@gentoo.org> 2005/03/26
	has_multilib_profile && ABI="x86"
}

src_install() {
	exeinto /opt/netscape/plugins
	doexe libflashplayer.so

	inst_plugin /opt/netscape/plugins/libflashplayer.so

	dodoc Readme.txt
}
