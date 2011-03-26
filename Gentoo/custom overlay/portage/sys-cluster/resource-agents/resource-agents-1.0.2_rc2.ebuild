# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

MY_PV="${PV/_/-}"
MY_P="Resource-agents-${MY_PV}"
VARIABLE_DATA="9/99"
inherit autotools multilib eutils base

DESCRIPTION="Library pack for Heartbeat / Pacemaker"
HOMEPAGE="http://www.linux-ha.org/wiki/Cluster_Glue"
SRC_URI="http://www.linux-ha.org/w/images/${VARIABLE_DATA}/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="sys-cluster/cluster-glue"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${PN}-${MY_PV}"

PATCHES=(
	"${FILESDIR}/${PV}-fix-autotools.patch"
	"${FILESDIR}/${PV}-fix-makefile.patch"
)

src_prepare() {
	base_src_prepare
	eautoreconf
}

src_configure() {
	econf \
		--disable-dependency-tracking \
		--localstatedir=/var \
		--docdir=/usr/share/doc/${PF} \
		--libdir=/usr/$(get_libdir) \
		--enable-libnet

	# wtfs
	# why it installs static libs
	# check dependencies
}
