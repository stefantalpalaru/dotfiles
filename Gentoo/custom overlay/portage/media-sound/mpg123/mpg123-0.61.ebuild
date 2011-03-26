# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/mpg123/mpg123-0.59s-r11.ebuild,v 1.10 2006/07/13 15:28:00 agriffis Exp $

inherit eutils toolchain-funcs

DESCRIPTION="Real Time mp3 player"
HOMEPAGE="http://www.mpg123.de/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="LGPL"
SLOT="0"

KEYWORDS="alpha amd64 hppa ia64 ~mips ppc ppc-macos ppc64 sparc x86"
IUSE="mmx 3dnow esd nas oss alsa sdl i586 i486"

RDEPEND="esd? ( media-sound/esound )
	nas? ( media-libs/nas )
	alsa? ( media-libs/alsa-lib )
	sdl? ( media-libs/libsdl )"

DEPEND="${RDEPEND}"

PROVIDE="virtual/mpg123"

src_unpack() {
	unpack ${A}
}

src_compile() {
	if use alsa; then
	 audiodev="alsa"
	 elif use oss; then
	  audiodev="oss"
	 elif use sdl; then
	  audiodev="sdl"
	 elif use esd; then
	  audiodev="esd"
	 elif use nas; then
	  audiodev="nas"
	 else die "no audio device selected"
	fi
	
	if use 3dnow; then
	 cpuopt="3dnow"
	 elif use mmx; then
	  cpuopt="mmx"
	 elif use i586; then
	  cpuopt="i586"
	 elif use i486; then
	  cpuopt="i486"
	 else cpuopt="i386_fpu"
	fi
	
	econf \
	      --with-optimization=0 \
	      --with-audio=$audiodev \
	      --with-cpu=$cpuopt || die
	      
	emake || die
}

src_install() {
	make DESTDIR=${D} install || die
}
