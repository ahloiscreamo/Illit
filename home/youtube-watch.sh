#!/bin/bash
# originally by Kris Occhipinti
# https://www.youtube.com/watch?v=FsQuGplQvrw

# Get URL from clipboard
url=$(/usr/bin/xclip -o -sel clip)

# Check if URL is empty
if [ -z "$url" ]; then
    /usr/bin/notify-send -t 3000 "Clipboard is empty" "No URL found to play."
    exit 1
fi

# Get title for the notification
title=$(/home/ahloi/.local/bin/yt-dlp --get-title "$url")

# Send notification
/usr/bin/notify-send -t 3000 "Playing Video" "$title"

# Play the video with mpv, telling it exactly which yt-dlp to use
# The '&' at the end runs the process in the background so it doesn't block the script.
/usr/bin/mpv --script-opts=ytdl_hook-ytdl_path=/home/ahloi/.local/bin/yt-dlp "$url" &