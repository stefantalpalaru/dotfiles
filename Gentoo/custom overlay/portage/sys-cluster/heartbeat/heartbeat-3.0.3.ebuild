# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

MY_PV="${PV/_/-}"
MY_P="STABLE-${MY_PV}"
inherit autotools multilib eutils base

DESCRIPTION="Heartbeat high availability cluster manager"
HOMEPAGE="http://www.linux-ha.org/wiki/Heartbeat"
SRC_URI="http://hg.linux-ha.org/heartbeat-STABLE_3_0/archive/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc snmp"

RDEPEND="
	sys-cluster/cluster-glue
	dev-libs/glib:2
	net-libs/libnet:1.1
	dev-lang/python
	net-misc/iputils
	virtual/ssh
	net-libs/gnutls
	snmp? ( net-analyzer/net-snmp )
	|| ( net-misc/netkit-telnetd net-misc/telnet-bsd )
	dev-lang/swig
	"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"
PDEPEND="sys-cluster/resource-agents"

S="${WORKDIR}/Heartbeat-3-0-STABLE-${MY_PV}"

PATCHES=(
	"${FILESDIR}/3.0.2_rc2-fix_configure.patch"
	#"${FILESDIR}/3.0.2_rc2-fix_makefile.patch"
)

src_prepare() {
	base_src_prepare
	eautoreconf
}

src_configure() {
	econf \
		--disable-dependency-tracking \
		--disable-fatal-warnings \
		--disable-tipc \
		--enable-libnet \
		--enable-ipmilan \
		--enable-dopd \
		--libdir=/usr/$(get_libdir) \
		--localstatedir=/var \
		$(use_enable snmp) \
		--with-group-id=65 --with-ccmuser-id=65
	# why it build all the .a files...
}

src_install() {
	base_src_install

	cp "${FILESDIR}"/heartbeat-init "${T}/" || die
	sed -i \
		-e "s:%libdir%:$(get_libdir):" \
		"${T}/heartbeat-init" || die
	newinitd "${T}/heartbeat-init" heartbeat || die

	# fix collisions
	rm -rf "${D}"/usr/include/heartbeat/{compress,ha_msg}.h

	if use doc ; then
		dodoc README doc/*.txt doc/AUTHORS  || die
	fi
}
