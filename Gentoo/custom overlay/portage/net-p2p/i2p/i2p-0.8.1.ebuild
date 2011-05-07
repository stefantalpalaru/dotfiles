# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="I2P is an anonymous network, exposing a simple layer that
applications can use to anonymously and securely send messages to each other."
SRC_URI="
		http://mirror.i2p2.de/${PN}source_${PV}.tar.bz2 
		http://dist.codehaus.org/jetty/jetty-5.1.x/jetty-5.1.15.tgz
		"
HOMEPAGE="http://www.i2p2.de"

SLOT="0"
KEYWORDS="~x86 ~amd64"
LICENSE="GPL-2"
IUSE="+initscript"
DEPEND="net-misc/wget
		>virtual/jdk-1.4
		${COMMON_DEP}"


S=${WORKDIR}/${PN}-${PV}

src_compile() {
	cd ${S} || die
	sed -i -e 's/source="1.4"/source="5"/g' -e 's/target="1.4"/target="1.5"/g' \
	build.xml */build.xml */*/build.xml */*/*/build.xml || die
	cp ${DISTDIR}/jetty-5.1.15.tgz ${S}/apps/jetty/ || die
	ant pkg
	while [ ! -d ${S}/pkg-temp ]; do
	echo "pkg-temp doesn't exist"
	rm ${S}/apps/jetty/verified.txt
	ant pkg
	done
	sed -i 's:^#\?PIDDIR=.*:PIDDIR=/var/run/:' \
		${S}/pkg-temp/i2prouter || die
	rm -f pkg-temp/*.bat pkg-temp/*.exe pkg-temp/lib/*.dll
	if use initscript ; then
		sed -i 's:[%$]INSTALL_PATH:/opt/i2p:' \
			${S}/pkg-temp/{eepget,i2prouter} ${S}/pkg-temp/*.config || die
		sed -i 's:[%$]SYSTEM_java_io_tmpdir:/opt/i2p/home:' \
			${S}/pkg-temp/{eepget,i2prouter} ${S}/pkg-temp/*.config || die
	else

		sed -i 's:[%$]INSTALL_PATH:/opt/i2p:' \
			${S}/pkg-temp/{eepget,i2prouter} ${S}/pkg-temp/*.config || die
		sed -i 's:[%$]SYSTEM_java_io_tmpdir:/tmp:' \
			${S}/pkg-temp/{eepget,i2prouter} ${S}/pkg-temp/*.config || die
		fi
	}

src_install() {
	insinto /opt/i2p
	exeinto /opt/i2p
	doins -r pkg-temp/*
	doexe pkg-temp/postinstall.sh pkg-temp/i2prouter pkg-temp/osid
	doexe pkg-temp/eepget pkg-temp/*.config

	if [ ${ARCH} == "x86" ] ; then
		doexe pkg-temp/lib/wrapper/linux/i2psvc
		exeinto /opt/i2p/lib
		doexe pkg-temp/lib/wrapper/linux/libwrapper.so
		doexe pkg-temp/lib/wrapper/linux/wrapper.jar
	elif [ ${ARCH} == "amd64" ] ; then
		doexe pkg-temp/lib/wrapper/linux64/i2psvc
		exeinto /opt/i2p/lib
		doexe pkg-temp/lib/wrapper/linux64/libwrapper.so
		doexe pkg-temp/lib/wrapper/linux64/wrapper.jar
	fi
	if use initscript ; then
		dodir /usr/bin /etc/init.d
		dosym /opt/i2p/i2prouter /usr/bin/i2prouter
		exeinto /etc/init.d
		doexe ${FILESDIR}/i2p
	else
		dodir /usr/bin
		dosym /opt/i2p/i2prouter /usr/bin/i2prouter
	fi
	}
pkg_postinst() {
	if use initscript; then
		enewgroup ${PN}
		enewuser ${PN} -1 -1 /opt/i2p/home/ ${PN} -m
		newinitd "${FILESDIR}"/i2p i2p
		einfo "Configure the router now : http://localhost:7657/index.jsp"
		einfo "Use /etc/init.d/i2p start to start I2P"
	else	
		einfo "Configure the router now : http://localhost:7657/index.jsp"
		einfo "Use 'i2prouter start' to run I2P and 'i2prouter stop' to stop it."
	fi
}
