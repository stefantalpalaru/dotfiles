#!/bin/sh

# This shell script is run before Openbox launches.
# Environment variables set here are passed to the Openbox session.

xset -dpms
Esetroot -c -s /home/stefan/src/images/wallpaper

# # D-bus
# if which dbus-launch >/dev/null && test -z "$DBUS_SESSION_BUS_ADDRESS"; then
#        eval `dbus-launch --sh-syntax --exit-with-session`
# fi

# Trust KB-2200 multimedia keyboard
#xmodmap /etc/X11/Xmodmap
#xbindkeys -f /etc/xbindkeys.conf

# Make GTK apps look and behave how they were set up in the gnome config tools
if test -x /usr/libexec/gnome-settings-daemon >/dev/null; then
 /usr/libexec/gnome-settings-daemon &
elif which gnome-settings-daemon >/dev/null; then
 gnome-settings-daemon &
 # Make GTK apps look and behave how they were set up in the XFCE config tools
elif which xfce-mcs-manager >/dev/null; then
 xfce-mcs-manager n &
fi


# Preload stuff for KDE apps
if which kdeinit4 >/dev/null; then
  LD_BIND_NOW=true kdeinit4 +kcminit_startup &
fi

# Run XDG autostart things.  By default don't run anything desktop-specific
# See xdg-autostart --help more info
DESKTOP_ENV="OPENBOX"
if which /usr/lib/openbox/xdg-autostart >/dev/null; then
 /usr/lib/openbox/xdg-autostart $DESKTOP_ENV
fi

# enable Ctrl+Alt+Backspace in xorg-server-1.6.1
setxkbmap -option terminate:ctrl_alt_bksp

