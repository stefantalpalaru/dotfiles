# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="A daemon built on ivman that executes arbitrary commands on HAL events"
HOMEPAGE="http://www.environnement.ens.fr/perso/dumas/halevt.html"
SRC_URI="http://www.environnement.ens.fr/perso/dumas/halevt-download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="nls"

DEPEND=">=sys-apps/hal-0.5.11-r1
		>=sys-apps/dbus-1.2.3-r1
		>=dev-libs/dbus-glib-0.76
		>=dev-libs/glib-2.16.5
		>=dev-libs/boolstuff-0.1.12"
RDEPEND=""

inherit eutils

src_unpack() {
	unpack ${P}.tar.gz
}



src_compile() {
	einfo "Running configure"
	econf \
		--localstatedir=/var \
		$(use_enable nls) \
	|| die "econf failed"

	einfo "Building ${P}"
	emake || die "emake failed"
}

src_install () {
	einfo "Running make install"
	emake DESTDIR="${D}" install || die "install failed"                                                                         
}

pkg_postinst () {
	enewgroup halevt
	enewuser halevt -1 -1 /dev/null "halevt,plugdev"
	if [[ ${ROOT} == / ]] ; then
		usermod -G "halevt,plugdev" halevt
	fi
	dodir /var/lib/halevt
	chown halevt:halevt /var/lib/halevt
}

