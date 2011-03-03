#!/bin/sh
# /etc/skel/.bashrc:
# $Header: /var/cvsroot/gentoo-x86/app-shells/bash/files/dot-bashrc,v 1.1 2005/04/30 00:08:01 vapier Exp $
# 
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.

# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]]; then
	# Shell is non-interactive.  Be done now
	return
fi

# Shell is interactive.  It is okay to produce output at this point,
# though this example doesn't produce any.  Do setup for
# command-line interactivity.

# colors for ls, etc.  Prefer ~/.dir_colors #64489
if [[ -f ~/.dir_colors ]]; then
	eval `dircolors -b ~/.dir_colors`
else
	eval `dircolors -b /etc/DIR_COLORS`
fi
alias ls="ls --color=auto"

# Change the window title of X terminals 
case $TERM in
	xterm*|rxvt|Eterm|eterm)
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007"'
		;;
	screen)
		PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\033\\"'
		;;
esac

export PATH="$PATH:/usr/local/bin:/usr/local/sbin:/opt/bin:/usr/games/bin:~/scripts:/usr/local/WordNet-2.1/bin:/usr/local/games:~/bin:/sbin"

###############
#  variables  #
###############

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

export EDITOR="vim"
export PAGER="less"
export BROWSER="firefox"
export CFLAGS="-O3 -march=prescott -pipe -fomit-frame-pointer -fno-ident"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-s"
export SVGALIB_DEFAULT_MODE=G640x480x256
#export GGI_DISPLAY="vcsa:-shade"
#export GGI_DEFMODE="80x40[T]"
export GGI_DISPLAY="svgalib"
export AAOPTS="-dim -bold -normal -boldfont -extended -eight"
export PS1="\[\033[0;31m\]\l \[\033[1;33m\]\d \[\033[1;36m\]\t \[\033[0;32m\]|\w|\[\033[0m\]\n\u\\$ "
export BC_ENV_ARGS="-lq /home/stefan/bc.rc"
export ECHANGELOG_USER="Stefan Talpalaru (stefantalpalaru) <stefantalpalaru@yahoo.com>"

#############
#  aliases  #
#############

alias ls='ls -AF --color=tty'
alias ll='ls -l'
alias du='du -h'
alias df='df -h'
alias calc='bc'
alias tetris='tetris-bsd -l9 -p'
alias info='pinfo'
#alias man='pinfo -m'
alias MKDOSFS='mkdosfs -f 1 -r 16 -F 12 -s 2 -S 512 /dev/fd0'
alias matrix='cmatrix -lbau 1; setfont lat2-12'
alias Lindent='indent -kr -i8 -ts8 -br -ce -bap -sob -l80 -pcs -cs -ss -bs -di0 -nbc -lp -psl'
alias cal='cal -m'
alias x='cd /src; startx'
alias set_wallpaper='Esetroot -c -s /home/stefan/src/images/wallpaper'
alias ink='escputil -iq -r /dev/usblp0'
alias gpull='find -name "*.pyc" -delete; git pull'
alias vlc='vlc --alsa-audio-device surround51'

export BREAK_CHARS="\"#'(),;\`\\|!?[]{}"
alias sbcl-rl="rlwrap -b \$BREAK_CHARS sbcl"


###############
#  functions  #
###############

newscript ()
{
if [ -z "$1" ]; then
 echo "usage: newscript <new file name>"
 return
fi
if [ -e "$1" ]; then
 echo "file '$1' allready exists"
 return
fi

case "$1" in
 *.pl)
  echo "#!/usr/bin/perl -w" > $1
 ;;
 *.py)
  echo "#!/usr/bin/python" > $1
 ;;
 *.lua)
  echo "#!/usr/bin/lua" > $1
 ;;
 *)
  echo \#\!/bin/sh > $1
 ;;
esac

echo >> $1
echo >> $1
chmod 755 $1
$EDITOR $1
}

unrpm ()
{
if [ -z "$1" ]; then
 echo "usage: unrpm <file.rpm>"
 return
fi
rpm2cpio $1 | cpio -div
}

[ -f ~/scripts/less.s ] && . ~/scripts/less.s

cls ()
{
 for tty in $@; do clear > /dev/tty$tty; done
}


asm ()
{
 [[ "$1" != *.s ]] && echo "usage: `basename $0` file.s" && return
 
 EXE=`basename $1 .s`
 OBJ=$EXE.o
 as $1 -o $OBJ && ld -s $OBJ -o $EXE
}

startvnc () 
{ 
 startx -- `which Xvfb` :1 -screen 0 1280x750x24 & sleep 5;
 x11vnc -display :1 -ncache 5 -forever -usepw -N;
 killall Xvfb
}

startvnc_real_screen ()
{
 x11vnc -display :0 -ncache 5 -forever -usepw -N
}


# bash-completion:
[ -f /etc/profile.d/bash-completion.sh ] && . /etc/profile.d/bash-completion.sh

