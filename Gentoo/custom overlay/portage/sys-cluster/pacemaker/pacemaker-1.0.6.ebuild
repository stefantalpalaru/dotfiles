# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

MY_PN="Pacemaker"
MY_P="${MY_PN}-${PV}"
inherit autotools multilib eutils base flag-o-matic

DESCRIPTION="Library pack for Heartbeat / Pacemaker"
HOMEPAGE="http://www.linux-ha.org/wiki/Cluster_Glue"
SRC_URI="http://hg.clusterlabs.org/${PN}/stable-1.0/archive/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="ais +heartbeat snmp"

RDEPEND="
	dev-libs/libxslt
	sys-cluster/cluster-glue
	sys-cluster/resource-agents
	ais? ( sys-cluster/openais )
	heartbeat? ( sys-cluster/heartbeat )
	snmp? ( net-analyzer/net-snmp )
	!ais? ( !heartbeat? ( sys-cluster/heartbeat ) )
"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_PN}-1-0-${MY_P}"

pkg_setup() {
	if ! use ais && ! use heartbeat; then
		ewarn "You disabled both cluster implementations"
		ewarn "Silently enabling heartbeat support."
	fi

	append-ldflags -Wl,--no-as-needed
}

src_prepare() {
	base_src_prepare
	eautoreconf
}

src_configure() {
	local myopts=""

	use ais || use heartbeat || myopts="--with-heartbeat"
	econf \
		--disable-dependency-tracking \
		--without-esnmp \
		$(use_with ais) \
		$(use_with heartbeat) \
		$(use_with snmp) \
		${myopts}
}
