# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#inherit linux-mod eutils libtool
inherit linux-mod

DESCRIPTION="Kernel module to allow compressing pages of memory."
HOMEPAGE="http://code.google.com/p/compcache/"
SRC_URI="http://compcache.googlecode.com/files/${P}.tar.gz"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
#SLOT="0"

pkg_setup() {
	CONFIG_CHECK="!BLK_DEV_COMPCACHE"
	ERROR_CFG="You already have compcache built into your kernel."
	linux-mod_pkg_setup
}

src_compile() {
	#declare -x ARCH="x86_64"
	emake || die "emake failed"
}

src_install() {
	einfo "Install"
	MODULE_NAMES="compcache(block) lzo1x_compress(block)
	tlsf(block) lzo1x_decompress(block)"
	linux-mod_src_install

	dodoc Changelog README
}

pkg_postinst() {
	linux-mod_pkg_postinst
	einfo " - To load compcache:"
	einfo "# modprobe compcache && sleep 2
	&& swapon /dev/ramzswap0 -p 100"
	einfo " - To unload compcache:"
	einfo "# swapoff /dev/ramzswap0 &&
	rmmod compcache && rmmod tlsf"
	einfo "Optionally modprobe can
	take the following arguments:"
	einfo "   -
	compcache_size_kbytes=$SIZE_KB
	(by default 25% of memory)"
	einfo "You might get lzo
	errors, ignore them."
	# todo : don't build
	# lzo modules if they
	# are in the kernel
	# already.
} 
