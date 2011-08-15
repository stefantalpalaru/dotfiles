# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

PYTHON_DEPEND="2:2.4"

inherit distutils

DESCRIPTION="Python implementation of the Flickr API."
HOMEPAGE="http://flickrapi.sourceforge.net/"
SRC_URI="mirror://pypi/f/${PN}/${P}.zip"
LICENSE="PSF-2.4"

SLOT="0"
KEYWORDS="~x86"
IUSE="test"

# Elementtree is required when Python is below 2.5
DEPEND=">=dev-python/setuptools-0.6.8
	dev-python/docutils"
RDEPEND=""

# Tests are interactive so skip it
