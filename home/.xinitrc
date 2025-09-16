~/.xinitrc
...

# general settings
xrdb -merge ~/.Xresources &

# pipewire
/usr/bin/pipewire &
/usr/bin/pipewire-pulse &
/usr/bin/wireplumber &

# disable dpms
xset dpms 0 0 0 && xset -dpms && xset s off && xset s noblank &

# daemon
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# mouse emulation
xkbset exp =mousekeys

# start i3
exec dbus-launch --exit-with-session i3
