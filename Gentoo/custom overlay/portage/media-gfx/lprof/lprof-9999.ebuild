# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit cmake-utils cvs

DESCRIPTION="Little CMS ICC profile construction set"
HOMEPAGE="http://lprof.sourceforge.net/"
SRC_URI=""
ECVS_SERVER="lprof.cvs.sourceforge.net:/cvsroot/lprof"
ECVS_MODULE="lprof"

LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="debug"

DEPEND="
	dev-libs/openssl
	media-libs/libpng
	media-libs/tiff
	virtual/jpeg
	media-libs/vigra
	sys-libs/zlib
	virtual/libusb
	x11-libs/qt-core:4[qt3support]
	x11-libs/qt-assistant:4
	x11-libs/libX11
"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${ECVS_MODULE}
DOCS=(README)
