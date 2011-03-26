# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/kid3/kid3-0.7.ebuild,v 1.4 2006/07/25 08:02:43 flameeyes Exp $

inherit kde

DESCRIPTION="A simple ID3 tag editor for QT/KDE."
HOMEPAGE="http://kid3.sourceforge.net/"
SRC_URI="mirror://sourceforge/kid3/${P}.tar.gz"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="flac vorbis"

DEPEND=">=media-libs/id3lib-3.8.3
	vorbis? ( media-libs/libvorbis )
	flac? ( media-libs/flac )"

need-kde 3


inherit eutils

src_unpack() {
	unpack ${A}
	cd ${S}

	epatch "${FILESDIR}/${P}-freedb2.patch"
}

# Support for the KDE libraries is optional,
# but the configure step that detects them
# cannot be avoided. So KDE support is forced on.
src_compile() {
	local myconf="--with-kde
				  $(use_with vorbis)
				  $(use_with flac)
				  --without-musicbrainz"

	kde_src_compile
}
