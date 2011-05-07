# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit qt4 subversion

DESCRIPTION="A cosmic recursive flame fractal editor"
HOMEPAGE="http://code.google.com/p/qosmic/"
SRC_URI=""
ESVN_REPO_URI="http://qosmic.googlecode.com/svn/branches/early-clip/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=dev-lang/lua-5.1.4
	=media-gfx/flam3-9999
	>=x11-libs/qt-gui-4.6:4"

src_prepare() {
	epatch "${FILESDIR}"/config.patch
	epatch "${FILESDIR}"/flam3.patch
}

src_compile() {
	eqmake4
}

src_install() {
	emake INSTALL_ROOT="${D}" install || die
	dodoc changes.txt README
}

