#!/bin/bash
set -eu

CONFIG_DIR="$HOME/.config/polybar"
SYMLINK_PATH="$CONFIG_DIR/config.ini"
THEME1_FILE="config-default.ini"
THEME2_FILE="config-no-block.ini"

# Resolve the current target of the symlink
# Using 'readlink -f' to get the canonical path, and then 'basename' to get just the filename
CURRENT_TARGET_BASENAME=$(basename "$(readlink -f "$SYMLINK_PATH")")

if [ "$CURRENT_TARGET_BASENAME" = "$THEME1_FILE" ]; then
    # Currently on theme 1 (config-default.ini), switch to theme 2 (config-no-block.ini)
    echo "Switching to $THEME2_FILE"
    ln -sf "$CONFIG_DIR/$THEME2_FILE" "$SYMLINK_PATH"
else
    # Currently on theme 2 (config-no-block.ini), switch to theme 1 (config-default.ini)
    echo "Switching to $THEME1_FILE"
    ln -sf "$CONFIG_DIR/$THEME1_FILE" "$SYMLINK_PATH"
fi

# Restart Polybar
echo "Restarting Polybar..."
"$CONFIG_DIR/launch.sh"

echo "Done."
