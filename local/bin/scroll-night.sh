#!/bin/bash
WAYBAR_DIR="$HOME/.config/waybar"
MODE_FILE="$WAYBAR_DIR/.mode"
DAY_CSS="$WAYBAR_DIR/style-day.css"
NIGHT_CSS="$WAYBAR_DIR/style-night.css"
DAWN_CSS="$WAYBAR_DIR/style-dawn.css"
ACTIVE_CSS="$WAYBAR_DIR/style.css"
ALACRITTY_TOML="$HOME/.config/alacritty/alacritty.toml"
FISH_CONFIG="$HOME/.config/fish/config.fish"
VIMRC="$HOME/.vimrc"
IMV_CONFIG="$HOME/.config/imv/config"
ROFI_CONFIG="$HOME/.config/rofi/config.rasi"
TMUX_CONF="/home/ahloi/.config/tmux/tmux.conf"

current=$(cat "$MODE_FILE" 2>/dev/null || echo "day")

if [ "$current" = "day" ]; then
    cp "$NIGHT_CSS" "$ACTIVE_CSS"
    echo "night" > "$MODE_FILE"
    sed -i 's|import = \["~/.config/alacritty/.*\.toml"\]|import = ["~/.config/alacritty/rose-pine-moon.toml"]|' "$ALACRITTY_TOML"
    sed -i 's|source ~/.config/fish/themes/fzf-.*.fish|source ~/.config/fish/themes/fzf-moon.fish|' "$FISH_CONFIG"
    sed -i 's/colorscheme rosepine.*/colorscheme rosepine_moon/' "$VIMRC"
    sed -i 's/set background=.*/set background=dark/' "$VIMRC"
    sed -i 's|source ~/.vim/themes/statusline-.*.vim|source ~/.vim/themes/statusline-moon.vim|' "$VIMRC"
    sed -i 's/background = #.*/background = #232136/' "$IMV_CONFIG"
    sed -i 's/overlay_background_color = #.*/overlay_background_color = #f6c177/' "$IMV_CONFIG"
    sed -i 's/overlay_text_color = #.*/overlay_text_color = #232136/' "$IMV_CONFIG"
    sed -i 's|^@theme ".*"|@theme "/home/ahloi/.local/share/rofi/themes/Rose-pine-moon-square-centered.rasi"|' "$ROFI_CONFIG"
    fish ~/.config/fish/themes/colors-moon.fish
    wallpaper "$HOME/Pictures/thinkpad.png"
    scrollmsg "client.focused #232136 #232136 #c8c8e5 #232136 #232136"
    scrollmsg "client.focused_inactive #232136 #232136 #6e6a86 #232136 #232136"
    scrollmsg "client.unfocused #232136 #232136 #6e6a86 #232136 #232136"
    scrollmsg "client.background #232136"
    sed -i "s/@rose_pine_variant '.*/@rose_pine_variant 'moon'/" "$TMUX_CONF"
    tmux source "$TMUX_CONF" 2>/dev/null
    notify-send -t 1500 "Waybar" "Night mode on" 2>/dev/null
elif [ "$current" = "night" ]; then
    cp "$DAWN_CSS" "$ACTIVE_CSS"
    echo "dawn" > "$MODE_FILE"
    sed -i 's|import = \["~/.config/alacritty/.*\.toml"\]|import = ["~/.config/alacritty/rose-pine-dawn.toml"]|' "$ALACRITTY_TOML"
    sed -i 's|source ~/.config/fish/themes/fzf-.*.fish|source ~/.config/fish/themes/fzf-dawn.fish|' "$FISH_CONFIG"
    sed -i 's/colorscheme rosepine.*/colorscheme rosepine_dawn/' "$VIMRC"
    sed -i 's/set background=.*/set background=light/' "$VIMRC"
    sed -i 's|source ~/.vim/themes/statusline-.*.vim|source ~/.vim/themes/statusline-dawn.vim|' "$VIMRC"
    sed -i 's/background = #.*/background = #faf4ed/' "$IMV_CONFIG"
    sed -i 's/overlay_background_color = #.*/overlay_background_color = #ea9d34/' "$IMV_CONFIG"
    sed -i 's/overlay_text_color = #.*/overlay_text_color = #faf4ed/' "$IMV_CONFIG"
    sed -i 's|^@theme ".*"|@theme "/home/ahloi/.local/share/rofi/themes/Rose-pine-dawn-square-centered.rasi"|' "$ROFI_CONFIG"
    fish ~/.config/fish/themes/colors-dawn.fish
    wallpaper "$HOME/Pictures/Bicycle.jpg"
    scrollmsg "client.focused #faf4ed #907aa9 #5a3e8a #cecacd #faf4ed"
    scrollmsg "client.focused_inactive #faf4ed #d7827e #8f4f4c #faf4ed #faf4ed"
    scrollmsg "client.unfocused #faf4ed #d7827e #8f4f4c #faf4ed #faf4ed"
    scrollmsg "client.background #faf4ed"
    sed -i "s/@rose_pine_variant '.*/@rose_pine_variant 'dawn'/" "$TMUX_CONF"
    tmux source "$TMUX_CONF" 2>/dev/null
    notify-send -t 1500 "Waybar" "Dawn mode on" 2>/dev/null
else
    cp "$DAY_CSS" "$ACTIVE_CSS"
    echo "day" > "$MODE_FILE"
    sed -i 's|import = \["~/.config/alacritty/.*\.toml"\]|import = ["~/.config/alacritty/rose-pine-moon.toml"]|' "$ALACRITTY_TOML"
    sed -i 's|source ~/.config/fish/themes/fzf-.*.fish|source ~/.config/fish/themes/fzf-moon.fish|' "$FISH_CONFIG"
    sed -i 's/colorscheme rosepine.*/colorscheme rosepine_moon/' "$VIMRC"
    sed -i 's/set background=.*/set background=dark/' "$VIMRC"
    sed -i 's|source ~/.vim/themes/statusline-.*.vim|source ~/.vim/themes/statusline-moon.vim|' "$VIMRC"
    sed -i 's/background = #.*/background = #232136/' "$IMV_CONFIG"
    sed -i 's/overlay_background_color = #.*/overlay_background_color = #f6c177/' "$IMV_CONFIG"
    sed -i 's/overlay_text_color = #.*/overlay_text_color = #232136/' "$IMV_CONFIG"
    sed -i 's|^@theme ".*"|@theme "/home/ahloi/.local/share/rofi/themes/Rose-pine-moon-square-centered.rasi"|' "$ROFI_CONFIG"
    fish ~/.config/fish/themes/colors-moon.fish
    wallpaper "$HOME/Pictures/Bicycle.jpg"
    scrollmsg "client.focused #232136 #c4a7e7 #7550a5 #56526e #232136"
    scrollmsg "client.focused_inactive #232136 #ea9a97 #a05550 #232136 #232136"
    scrollmsg "client.unfocused #232136 #ea9a97 #a05550 #232136 #232136"
    scrollmsg "client.background #232136"
    sed -i "s/@rose_pine_variant '.*/@rose_pine_variant 'moon'/" "$TMUX_CONF"
    tmux source "$TMUX_CONF" 2>/dev/null
    notify-send -t 1500 "Waybar" "Day mode on" 2>/dev/null
fi
pkill -SIGUSR2 waybar
