#!/bin/bash
MODE_FILE="$HOME/.config/waybar/.mode"
current=$(cat "$MODE_FILE" 2>/dev/null || echo "day")

if [ "$current" = "night" ]; then
    scrollmsg "client.focused #232136 #232136 #c8c8e5 #232136 #232136"
    scrollmsg "client.focused_inactive #232136 #232136 #6e6a86 #232136 #232136"
    scrollmsg "client.unfocused #232136 #232136 #6e6a86 #232136 #232136"
else
    scrollmsg "client.focused #232136 #c4a7e7 #7550a5 #56526e #232136"
    scrollmsg "client.focused_inactive #232136 #ea9a97 #a05550 #232136 #232136"
    scrollmsg "client.unfocused #232136 #ea9a97 #a05550 #232136 #232136"
fi
