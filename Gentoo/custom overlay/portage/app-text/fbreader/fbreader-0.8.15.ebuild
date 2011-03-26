# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="E-Book Reader. Supports several e-book formats: fb2 (fictionbook), html, chm, plucker, palmdoc, zTxt, tcr, rtf, oeb, openreader, mpbipocket and plain text. Also provides direct reading from tar, zip, gzip and bzip2 archives, including support of multiple books in one archive"
HOMEPAGE="http://www.fbreader.org/"
SRC_URI="http://www.fbreader.org/${PN}-sources-${PV}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"

IUSE="qt3 qt4 gtk debug"
DEPEND="dev-libs/expat
	app-arch/bzip2
	qt4? ( =x11-libs/qt-4* )
	qt3? ( =x11-libs/qt-3* )
	gtk? ( >=x11-libs/gtk+-2.4 )
	"
RDEPEND="${DEPEND}"

pkg_setup() {
	local toolkitsnum toolkitstypes="qt3 qt4 gtk" toolkitstype
	declare -i toolkitsnum=0
	for toolkitstype in ${toolkitstypes}; do
		useq ${toolkitstype} && let toolkitsnum++
	done
	if [ ${toolkitsnum} -gt 1 ]; then
		eerror
		eerror "You can't use more than one of toolkits."
		eerror "Select exactly one toolkits type out of these: ${toolkitstypes}"
		eerror
		die "Multiple toolkits types selected."
	elif [ ${toolkitsnum} -lt 1 ]; then
		eerror
		eerror "Select exactly one toolkits type out of these: ${toolkitstypes}"
		eerror
		die "No toolkits type selected."
	fi
}

src_unpack() {
	unpack ${A}
	cd ${S}
	sed -i -e "s:FBReader.png:fbreader.png:" fbreader/desktop/Makefile
	sed -i -e "s:@install -m 0644 desktop \$(DESTDIR)/usr/share/applications/\$(TARGET).desktop::" fbreader/desktop/Makefile
}

src_compile () {
	
	cd ${S}
	sed -i "s:INSTALLDIR=/usr/local:INSTALLDIR=/usr:" makefiles/arch/desktop.mk || die "updating desktop.mk failed"
	echo "TARGET_ARCH = desktop" > makefiles/target.mk

	if use qt4 ; then
	# qt4
		echo "UI_TYPE = qt4" >> makefiles/target.mk

		sed -i "s:MOC = moc-qt4:MOC = /usr/bin/moc:" makefiles/arch/desktop.mk || die "updating desktop.mk failed"
		sed -i "s:UILIBS = -lQtGui:UILIBS = -L/usr/lib/qt4 -lQtGui:" makefiles/arch/desktop.mk
	fi

	if use qt3 ; then
	# qt3
		echo "UI_TYPE = qt" >> makefiles/target.mk

		sed -i "s:MOC = moc-qt3:MOC = ${QTDIR}/bin/moc:" makefiles/arch/desktop.mk || die "updating desktop.mk failed"
		sed -i "s:QTINCLUDE = -I /usr/include/qt3:QTINCLUDE = -I ${QTDIR}/include:" makefiles/arch/desktop.mk || die "updating desktop.mk failed"
		sed -i "s:UILIBS = -lqt-mt:UILIBS = -L${QTDIR}/lib -lqt-mt:" makefiles/arch/desktop.mk

	fi
	
	if use gtk ; then
	# gtk
		echo "UI_TYPE = gtk" >> makefiles/target.mk
	fi
	
	if use debug ; then
		echo "TARGET_STATUS = debug" >> makefiles/target.mk
	else
		echo "TARGET_STATUS = release" >> makefiles/target.mk
	fi

	emake || die "emake failed"
}

src_install()
{
	emake DESTDIR=${D} install || die "install failed"
	
	for res in 16 32 48; do
		insinto /usr/share/icons/hicolor/${res}x${res}/apps/
		newins "${S}"/fbreader/icons/application/${res}x${res}.png fbreader.png
	done

	cat > x-fb2.desktop <<-EOF
		[Desktop Entry]
		Comment=FictionBook file
		Icon=fbreader
		MimeType=application/x-fb2
		Patterns=*.fb2;*.fb2.zip;
		Type=MimeType
	EOF

	cat > fbreader.desktop <<-EOF
		[Desktop Entry]
		Encoding=UTF-8
		Name=FBReader
		Comment=FictionBook file
		Icon=fbreader
		Exec=fbreader %f
		MimeType=application/x-fb2
		Terminal=false
		Type=Application
		Categories=Application;Office;Viewer;
	EOF
	
	insinto /usr/share/mimelnk/application
	doins x-fb2.desktop
	insinto /usr/share/applications/
	doins fbreader.desktop

	dosym /usr/bin/FBReader /usr/bin/fbreader
}


