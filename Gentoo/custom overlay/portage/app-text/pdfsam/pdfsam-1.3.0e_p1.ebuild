# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc"
inherit java-pkg-2 eutils java-ant-2 versionator

MY_P="${P/_p/-sr}"
MY_BV="1"

DESCRIPTION="A free open source tool to split and merge pdf documents"
HOMEPAGE="http://www.pdfsam.org/"
SRC_URI="http://ftp.mars.arge.at/pub/${MY_P}-build-${MY_BV}-src.zip
        mirror://sourceforge/${PN}/${MY_P}-out-src.zip"
LICENSE="GPL-2.1"
SLOT="1.3"
KEYWORDS="~amd64 ~ia64 ~ppc ~ppc64 ~x86 ~x86-fbsd"
IUSE=""

S="${WORKDIR}"

COMMON_DEP="=dev-java/jcmdline-1.0*
	>=dev-java/itext-2.0.4
	>=dev-java/jaxen-1.0
	>=dev-java/bcmail-1.35
	>=dev-java/bcprov-1.35
	>=dev-java/jgoodies-looks-2.0
	>=dev-java/dom4j-1.5"
RDEPEND=">=virtual/jre-1.5
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.5
	sys-devel/gettext
	app-arch/unzip
	${COMMON_DEP}"
	
src_unpack() {
	unpack ${A}
	cd ${S}
	java-pkg_jarfrom jcmdline-1.0
	java-pkg_jarfrom itext
	java-pkg_jarfrom dom4j-1
	java-pkg_jarfrom jaxen-1.1
	java-pkg_jarfrom bcmail
	java-pkg_jarfrom bcprov
	java-pkg_jarfrom jgoodies-looks-2.0
}

src_compile() {
	eant -Dbuild.dir=${S}/build \
	     -Dsrc.dir=${S} \
	     -Djcmdline.location=${S} \
	     -Ditext.location=${S} \
	     -Ddom4j.location=${S} \
	     -Djaxen.location=${S} \
	     -Dbcmail.location=${S} \
	     -Dbcprov.location=${S} \
	     -Djgoodies-looks.location=${S} ${antflags}

	use doc && eant -Dbuild.dir=${S}/build \
	     -Dsrc.dir=${S} \
	     -Djcmdline.location=${S} \
	     -Ditext.location=${S} \
	     -Ddom4j.location=${S} \
	     -Djaxen.location=${S} \
	     -Dbcmail.location=${S} \
	     -Dbcprov.location=${S} \
	     -Djgoodies-looks.location=${S} ${antflags} javadoc
}

src_install() {
	insinto /usr/share/${PN}-${SLOT}/lib
	doins ${S}/dist/pdfsam-maine/*.xml
	java-pkg_newjar ${S}/dist/pdfsam-maine/pdfsam-*.jar pdfsam.jar
	java-pkg_newjar ${S}/dist/pdfsam-maine/lib/pdfsam-console-*.jar pdfsam-console.jar 
	java-pkg_newjar ${S}/dist/pdfsam-maine/lib/pdfsam-langpack-*.jar pdfsam-langpack.jar 

	for plugins in merge cover split encrypt mix
	do
	    java-pkg_jarinto /usr/share/${PN}-${SLOT}/lib/plugins/${plugins}
	    insinto /usr/share/${PN}-${SLOT}/lib/plugins/${plugins}
	    
	    java-pkg_dojar ${S}/dist/pdfsam-maine/plugins/${plugins}/*.jar
	    doins ${S}/dist/pdfsam-maine/plugins/${plugins}/*.xml
	done
	
	java-pkg_dolauncher ${PN} --main it.pdfsam.GUI.MainGUI --pwd "/usr/share/${PN}-${SLOT}/lib"
	java-pkg_dolauncher ${PN}-console --main it.pdfsam.console.MainConsole --pwd "/usr/share/${PN}-${SLOT}/lib"

        newicon ${S}/pdfsam-maine/images/pdf.png pdfsam.png
        make_desktop_entry ${PN} "PDF Split and Merge" pdfsam.png Office

	dodoc pdfsam-maine/doc/* || die
	
	use doc && java-pkg_dojavadoc dist/pdfsam-javadoc
}
