#!/bin/bash
WAYBAR_DIR="$HOME/.config/waybar"
MODE_FILE="$WAYBAR_DIR/.mode"
DAY_CSS="$WAYBAR_DIR/style-day.css"
NIGHT_CSS="$WAYBAR_DIR/style-night.css"
ACTIVE_CSS="$WAYBAR_DIR/style.css"
current=$(cat "$MODE_FILE" 2>/dev/null || echo "day")
if [ "$current" = "day" ]; then
    cp "$NIGHT_CSS" "$ACTIVE_CSS"
    echo "night" > "$MODE_FILE"
    scrollmsg "client.focused #232136 #232136 #c8c8e5 #232136 #232136"
    scrollmsg "client.focused_inactive #232136 #232136 #6e6a86 #232136 #232136"
    scrollmsg "client.unfocused #232136 #232136 #6e6a86 #232136 #232136"
    notify-send -t 1500 "Waybar" "Night mode on" 2>/dev/null
else
    cp "$DAY_CSS" "$ACTIVE_CSS"
    echo "day" > "$MODE_FILE"
    scrollmsg "client.focused #232136 #c4a7e7 #7550a5 #56526e #232136"
    scrollmsg "client.focused_inactive #232136 #ea9a97 #a05550 #232136 #232136"
    scrollmsg "client.unfocused #232136 #ea9a97 #a05550 #232136 #232136"
    notify-send -t 1500 "Waybar" "Day mode on" 2>/dev/null
fi
pkill -SIGUSR2 waybar
