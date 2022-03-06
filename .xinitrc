#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
# TODO Figure out how to handle nix store resources
#sysresources=/nix/store/5hwha4z3c43z0k882j638jkhbl1b3hz3-xinit-1.4.1/etc/X11/xinit/.Xresources
#sysmodmap=/nix/store/5hwha4z3c43z0k882j638jkhbl1b3hz3-xinit-1.4.1/etc/X11/xinit/.Xmodmap

# start dbus daemon

if test -z "$DBUS_SESSION_BUS_ADDRESS"; then
    eval $(dbus-launch --exit-with-session --sh-syntax)
fi
systemctl --user import-environment DISPLAY XAUTHORITY

if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    dbus-update-activation-environment DISPLAY XAUTHORITY
fi

# merge in defaults and keymaps

#if [ -f $sysresources ]; then
#    xrdb -merge $sysresources
#fi

#if [ -f $sysmodmap ]; then
#    xmodmap $sysmodmap
#fi

if [ -f $userresources ]; then
    xrdb -merge $userresources
fi

if [ -f $usermodmap ]; then
    xmodmap $usermodmap
fi

# start some nice programs

exec xmonad >> $HOME/.cache/xmonad-logs/xmonad-log-$(date +'%F-%k-%M-%S').txt 2>&1
