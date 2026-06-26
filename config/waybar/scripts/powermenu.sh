#!/bin/sh
choice=$(printf "Logout\nReboot\nShutdown" | rofi -dmenu -p "Power")
case $choice in
    Logout) scrollmsg exit ;;
    Reboot) reboot ;;
    Shutdown) poweroff ;;
esac
