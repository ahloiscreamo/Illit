#!/bin/bash
# originally by Kris Occhipinti
# https://www.youtube.com/watch?v=FsQuGplQvrw

url=$(xclip -o -sel clip)
title=$(yt-dlp --get-title "$url")

notify-send -t 3000 "Playing Video" "$title";
mpv "$url"