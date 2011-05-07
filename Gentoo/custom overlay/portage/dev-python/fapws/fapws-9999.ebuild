# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EGIT_REPO_URI="git://github.com/william-os4y/fapws3.git"
EAPI="2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3*"

inherit distutils git

DESCRIPTION="Fast Asynchronous Python Web Server using libev"
HOMEPAGE="http://github.com/william-os4y/fapws3"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE=""
DEPEND="dev-libs/libev"
RDEPEND="${DEPEND}"

