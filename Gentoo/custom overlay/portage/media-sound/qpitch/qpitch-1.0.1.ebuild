# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"

inherit eutils cmake-utils

DESCRIPTION="A program to tune musical instruments using Qt 4."
HOMEPAGE="http://wspinell.altervista.org/qpitch/"
SRC_URI="http://wspinell.altervista.org/qpitch/files/${P}.tar.bz2"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"

DEPEND=">=x11-libs/qt-4.2:4
        >=media-libs/portaudio-19_pre20071207
        >=sci-libs/fftw-3.1.0"

RDEPEND="${DEPEND}"

src_unpack () {
	unpack ${A}
	cd "${S}"
	epatch ${FILESDIR}/add-cmake-minimum-version.patch
	epatch ${FILESDIR}/add-make-install.patch
}
