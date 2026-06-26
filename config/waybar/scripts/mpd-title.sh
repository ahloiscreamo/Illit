#!/bin/sh
artist=$(mpc current --format '%artist%' 2>/dev/null)
title=$(mpc current --format '%title%' 2>/dev/null)
if [ -n "$artist" ]; then
    echo "{\"text\": \"<span rise=\\\"-2000\\\" foreground=\\\"#eb6f92\\\"></span> $artist <span rise=\\\"-2000\\\" foreground=\\\"#eb6f92\\\"></span> $title\"}"
else
    echo "{\"text\": \"<span rise=\\\"-2000\\\" foreground=\\\"#3e8fb0\\\"></span> MPD OFF\"}"
fi
