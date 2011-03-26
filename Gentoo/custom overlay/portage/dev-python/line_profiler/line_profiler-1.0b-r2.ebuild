# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"

inherit distutils

MY_P=${P}2

DESCRIPTION="line-by-line profiler"
HOMEPAGE="http://pypi.python.org/pypi/line_profiler"
SRC_URI="http://pypi.python.org/packages/source/${PN:0:1}/${PN}/${MY_P}.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S=${S}2

