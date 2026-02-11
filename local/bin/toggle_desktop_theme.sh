#!/bin/bash
#
# Toggles between two color schemes for both i3 and Polybar.
# It uses the i3 config file as the source of truth for the current theme.

set -eu

# --- Configuration ---
I3_CONFIG="/home/ahloi/.config/i3/config"
POLYBAR_CONFIG_DIR="/home/ahloi/.config/polybar"

# i3 Theme IDs (from i3 config)
I3_THEME_LIGHT="rosepine"
I3_THEME_DARK="rosepine-dark"

# Polybar Theme Files (symlink target)
# Assuming 'default' is the light theme and 'no-block' is the dark theme.
# If this is wrong, swap the two lines below.
POLYBAR_THEME_LIGHT="config-default.ini"
POLYBAR_THEME_DARK="config-no-block.ini"

# --- Logic ---

# Read the current theme from the state comment in the i3 config
CURRENT_THEME=$(grep -oP '# CURRENT_THEME=\K.*' "$I3_CONFIG")

if [ "$CURRENT_THEME" = "$I3_THEME_LIGHT" ]; then
  # === SWITCH TO DARK THEME ===
  echo "Switching to DARK theme ($I3_THEME_DARK)..."

  # 1. Update i3 State & Theme
  sed -i "s/# CURRENT_THEME=$I3_THEME_LIGHT/# CURRENT_THEME=$I3_THEME_DARK/" "$I3_CONFIG"
  sed -i "/# THEME_START: $I3_THEME_LIGHT/,/# THEME_END: $I3_THEME_LIGHT/s/^\(client\)/#\1/" "$I3_CONFIG"
  sed -i "/# THEME_START: $I3_THEME_DARK/,/# THEME_END: $I3_THEME_DARK/s/^#\(client\)/\1/" "$I3_CONFIG"
  
  # 2. Update Polybar Symlink
  echo "Switching Polybar to $POLYBAR_THEME_DARK"
  ln -sf "$POLYBAR_CONFIG_DIR/$POLYBAR_THEME_DARK" "$POLYBAR_CONFIG_DIR/config.ini"

else
  # === SWITCH TO LIGHT THEME ===
  echo "Switching to LIGHT theme ($I3_THEME_LIGHT)..."

  # 1. Update i3 State & Theme
  sed -i "s/# CURRENT_THEME=$I3_THEME_DARK/# CURRENT_THEME=$I3_THEME_LIGHT/" "$I3_CONFIG"
  sed -i "/# THEME_START: $I3_THEME_LIGHT/,/# THEME_END: $I3_THEME_LIGHT/s/^#\(client\)/\1/" "$I3_CONFIG"
  sed -i "/# THEME_START: $I3_THEME_DARK/,/# THEME_END: $I3_THEME_DARK/s/^\(client\)/#\1/" "$I3_CONFIG"

  # 2. Update Polybar Symlink
  echo "Switching Polybar to $POLYBAR_THEME_LIGHT"
  ln -sf "$POLYBAR_CONFIG_DIR/$POLYBAR_THEME_LIGHT" "$POLYBAR_CONFIG_DIR/config.ini"
fi

# --- Reload Services ---
echo "Reloading i3 and restarting Polybar..."
i3-msg reload
"$POLYBAR_CONFIG_DIR/launch.sh" &

echo "Done."
