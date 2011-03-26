# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:$

EAPI=2

DESCRIPTION="GIMP plug-in with G'MIC large number of predefined filters"
HOMEPAGE="http://gmic.sourceforge.net/gimp.shtml"
SRC_URI="mirror://sourceforge/gmic/gmic_${PV}.tar.gz"
LICENSE="CeCILL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND="media-gfx/gimp[tiff,png,jpeg]
	media-libs/libpng
	sci-libs/fftw:3.0
	sys-libs/zlib"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S="${WORKDIR}/gmic-${PV}/src"

src_prepare() {
	sed -e 's:^\(OPT_CFLAGS *=\).*:\1:' \
		-e '/^\tstrip gmic/d' \
		-i Makefile || die "sed failed"
}

src_compile() {
	emake gimp || die "Compilation failed"
}

src_install() {
	exeinto "$(pkg-config --variable=gimplibdir gimp-2.0)/plug-ins"
	doexe gmic_gimp || die "Installation failed"
}

pkg_postinst() {
	elog "The G'MIC plugin is accessible from the menu:"
	elog "Filters -> G'MIC"
}
