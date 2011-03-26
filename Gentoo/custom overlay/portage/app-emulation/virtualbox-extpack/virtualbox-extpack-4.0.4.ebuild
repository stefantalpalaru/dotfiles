# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils

MY_BUILD="70112"

DESCRIPTION="extension pack for VirtualBox"
HOMEPAGE="http://www.virtualbox.org/"
SRC_URI="http://download.virtualbox.org/virtualbox/${PV}/Oracle_VM_VirtualBox_Extension_Pack-${PV}-${MY_BUILD}.vbox-extpack -> Oracle_VM_VirtualBox_Extension_Pack-${PV}-${MY_BUILD}.tar.gz"

LICENSE="PUEL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror"

RDEPEND="~app-emulation/virtualbox-${PV}"

src_install() {
	mkdir -p "${D}"/usr/$(get_libdir)/virtualbox/ExtensionPacks/Oracle_VM_VirtualBox_Extension_Pack
	cp -r * "${D}"/usr/$(get_libdir)/virtualbox/ExtensionPacks/Oracle_VM_VirtualBox_Extension_Pack
}

