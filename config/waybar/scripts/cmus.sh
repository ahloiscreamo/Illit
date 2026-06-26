#!/bin/bash

# Keep Pango happy so it doesn't crash on titles with '&' or '<'
escape_pango() {
    echo "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'
}

# Define your color palette here
active_color="#eb6f92"   # Vibrant rose/pink when playing
paused_color="#f6c177"   # Warm gold when paused
inactive_color="#6e6a86" # Muted slate/gray when stopped

# Choose your icons (or leave them empty if you don't use icons)
playing_icon=""
paused_icon=""
stopped_icon=""

# Make sure cmus is actually running, otherwise exit quietly and show nothing
output=$(cmus-remote -C status 2>/dev/null)
if [ $? -ne 0 ] || [ -z "$output" ]; then
    echo ""
    exit 0
fi

# Pull out the song info we care about
artist=$(echo "$output" | grep "^tag artist" | cut -c 12-)
path=$(echo "$output" | grep "^file" | cut -c 12-)
cmusstatus=$(echo "$output"| grep "^status" | cut -c 8-)

# Escape any special XML/HTML chars in our variables
artist=$(escape_pango "$artist")
path=$(escape_pango "$path")

# Assign colors and icons dynamically based on cmus state
case $cmusstatus in
    "playing")
        icon="$playing_icon"
        current_color="$active_color"
        ;;
    "paused")
        icon="$paused_icon"
        current_color="$paused_color"
        ;;
"stopped")
        # When stopped, print the inactive icon in the inactive color
        echo -e "<span color=\"$inactive_color\">$stopped_icon Stopped</span>"
        exit 0
        ;;
esac

# Formulate the output depending on whether artist/song info exists
if [[ $artist = *[!\ ]* ]]; then
song=$(echo "$output" | grep "^tag title" | cut -c 11-)
song=$(escape_pango "$song")

# OPTION A: If you want ONLY the icons and hyphens colored:
echo -e "<span color=\"$current_color\">$icon</span> $artist <span color=\"$current_color\">-</span> $song"

elif [[ $path = *[!\ ]* ]]; then
IFS="/"
read -ra parts <<< "$path"
for i in "${parts[@]}"; do
        file=$i
done

# Output filename fallback
echo -e "<span color=\"$current_color\">$icon $file</span>"
else
    echo -e "<span color=\"$inactive_color\">$stopped_icon</span>"
fi

