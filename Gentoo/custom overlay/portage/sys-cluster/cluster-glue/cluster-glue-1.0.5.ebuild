# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

MY_PV="${PV/_/-}"
MY_P="glue-${MY_PV}"
inherit autotools multilib eutils base

DESCRIPTION="Library pack for Heartbeat / Pacemaker"
HOMEPAGE="http://www.linux-ha.org/wiki/Cluster_Glue"
SRC_URI="http://hg.linux-ha.org/glue/archive/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

RDEPEND="app-arch/bzip2
	net-libs/libnet:1.1
	net-misc/curl
	net-misc/iputils
	|| ( net-misc/netkit-telnetd net-misc/telnet-bsd )
	dev-libs/libxml2"
DEPEND="${RDEPEND}
	doc? ( dev-libs/libxslt )"

S="${WORKDIR}/Reusable-Cluster-Components-glue-${MY_PV}"

PATCHES=(
	"${FILESDIR}/1.0.2_rc2-fix_autotools.patch"
	"${FILESDIR}/1.0.2_rc2-fix_makefile.patch"
)

src_prepare() {
	base_src_prepare
	eautoreconf
}

src_configure() {
	local myopts

	use doc && myopts=" --enable-doc"
	econf \
		--disable-dependency-tracking \
		--docdir=/usr/share/doc/${PF} \
		--enable-libnet \
		--localstatedir=/var \
		--sysconfdir=/etc \
		${myopts} \
		--with-group-id=65 --with-ccmuser-id=65 \
		--with-daemon-user=hacluster --with-daemon-group=hacluster

	# wtfs
	# why it installs static libs
	# check dependencies
}

src_install() {
	base_src_install

	dodir /var/lib/heartbeat/cores
	dodir /var/lib/heartbeat/lrm

	keepdir /var/lib/heartbeat/cores
	keepdir /var/lib/heartbeat/lrm

	# init.d file
	cp "${FILESDIR}"/heartbeat-logd.init "${T}/" || die
	sed -i \
		-e "s:%libdir%:$(get_libdir):" \
		"${T}/heartbeat-logd.init" || die
	newinitd "${T}/heartbeat-logd.init" heartbeat-logd || die
	rm "${D}"/etc/init.d/logd
}

pkg_preinst() {
	# check for cluster group, if it doesn't exist make it
	groupadd -g 65 hacluster
	# check for cluster user, if it doesn't exist make it
	useradd -u 65 -g hacluster -s /dev/null -d /var/lib/heartbeat hacluster
}

pkg_postinst() {
	chown -R hacluster:hacluster /var/lib/heartbeat/cores
	chown -R hacluster:hacluster /var/lib/heartbeat/lrm
}
