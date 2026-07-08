#!/bin/bash
MODE_FILE="$HOME/.config/waybar/.mode"
current=$(cat "$MODE_FILE" 2>/dev/null || echo "day")
if [ "$current" = "night" ]; then
    scrollmsg "client.focused #232136 #232136 #c8c8e5 #232136 #232136"
    scrollmsg "client.focused_inactive #232136 #232136 #6e6a86 #232136 #232136"
    scrollmsg "client.unfocused #232136 #232136 #6e6a86 #232136 #232136"
    scrollmsg "client.background #232136"
    gsettings set org.gnome.desktop.interface gtk-theme "Rosepine-Red-Dark-Moon"
    gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
    wallpaper "$HOME/Pictures/thinkpad.png"
elif [ "$current" = "dawn" ]; then
    scrollmsg "client.focused #faf4ed #907aa9 #5a3e8a #cecacd #faf4ed"
    scrollmsg "client.focused_inactive #faf4ed #d7827e #8f4f4c #faf4ed #faf4ed"
    scrollmsg "client.unfocused #faf4ed #d7827e #8f4f4c #faf4ed #faf4ed"
    scrollmsg "client.background #faf4ed"
    gsettings set org.gnome.desktop.interface gtk-theme "Rosepine-Pink-Light"
    gsettings set org.gnome.desktop.interface icon-theme "Papirus-Light"
    wallpaper "$HOME/Pictures/Bicycle.jpg"
else
    scrollmsg "client.focused #232136 #c4a7e7 #7550a5 #56526e #232136"
    scrollmsg "client.focused_inactive #232136 #ea9a97 #a05550 #232136 #232136"
    scrollmsg "client.unfocused #232136 #ea9a97 #a05550 #232136 #232136"
    scrollmsg "client.background #232136"
    gsettings set org.gnome.desktop.interface gtk-theme "Rosepine-Red-Dark-Moon"
    gsettings set org.gnome.desktop.interface icon-theme "Papirus"
    wallpaper "$HOME/Pictures/Bicycle.jpg"
fi
