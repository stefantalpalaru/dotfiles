# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit autotools gnome2

EAPI=2

DESCRIPTION="An opensource binaural-beat generator"
HOMEPAGE="http://gnaural.sourceforge.net"
SRC_URI="mirror://sourceforge/project/${PN}/Gnaural/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="nls"

RDEPEND="
	>=x11-libs/gtk+-2
	>=gnome-base/libglade-2
	>=dev-libs/glib-2
	>=media-libs/libsndfile-1.0.2
	>=media-libs/portaudio-19_pre20071207"

DEPEND="
	${RDEPEND}
	nls? ( dev-util/intltool )
	dev-util/pkgconfig"

src_configure() {
	econf $(use_enable nls)
}

