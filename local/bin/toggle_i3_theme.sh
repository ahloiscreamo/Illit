#!/bin/bash
#
# Toggles between two color schemes in the i3 config file and reloads i3.

set -eu

I3_CONFIG="/home/ahloi/.config/i3/config"
THEME1_ID="rosepine"
THEME2_ID="rosepine-dark"

# Read the current theme from the state comment
CURRENT_THEME=$(grep -oP '# CURRENT_THEME=\K.*' "$I3_CONFIG")

if [ "$CURRENT_THEME" = "$THEME1_ID" ]; then
  # SWITCH TO THEME 2 (rosepine-dark)

  # Update state
  sed -i "s/# CURRENT_THEME=$THEME1_ID/# CURRENT_THEME=$THEME2_ID/" "$I3_CONFIG"

  # Comment Theme 1 lines
  sed -i "/# THEME_START: $THEME1_ID/,/# THEME_END: $THEME1_ID/s/^\(client\)/#\1/" "$I3_CONFIG"
  
  # Uncomment Theme 2 lines
  sed -i "/# THEME_START: $THEME2_ID/,/# THEME_END: $THEME2_ID/s/^#\(client\)/\1/" "$I3_CONFIG"

else
  # SWITCH TO THEME 1 (rosepine)

  # Update state
  sed -i "s/# CURRENT_THEME=$THEME2_ID/# CURRENT_THEME=$THEME1_ID/" "$I3_CONFIG"

  # Uncomment Theme 1 lines
  sed -i "/# THEME_START: $THEME1_ID/,/# THEME_END: $THEME1_ID/s/^#\(client\)/\1/" "$I3_CONFIG"

  # Comment Theme 2 lines
  sed -i "/# THEME_START: $THEME2_ID/,/# THEME_END: $THEME2_ID/s/^\(client\)/#\1/" "$I3_CONFIG"
fi

# Reload i3 to apply changes
i3-msg reload