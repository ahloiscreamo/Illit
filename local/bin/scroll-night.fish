#!/usr/bin/env fish
set WAYBAR_DIR $HOME/.config/waybar
set MODE_FILE $WAYBAR_DIR/.mode
set DAY_CSS $WAYBAR_DIR/style-day.css
set NIGHT_CSS $WAYBAR_DIR/style-night.css
set DAWN_CSS $WAYBAR_DIR/style-dawn.css
set ACTIVE_CSS $WAYBAR_DIR/style.css
set ALACRITTY_TOML $HOME/.config/alacritty/alacritty.toml
set FISH_CONFIG $HOME/.config/fish/config.fish
set VIMRC $HOME/.vimrc
set IMV_CONFIG $HOME/.config/imv/config
set ROFI_CONFIG $HOME/.config/rofi/config.rasi
set TMUX_CONF /home/ahloi/.config/tmux/tmux.conf
set DUNSTRC $HOME/.config/dunst/dunstrc
set KITTY_CONF $HOME/.config/kitty/kitty.conf
set YTM_CONFIG $HOME/.config/ytm-player/config.toml
set YTM_THEME $HOME/.config/ytm-player/theme.toml

function apply_ytm_theme
    set mode $argv[1]
    set ytm_theme_name playback_bar_bg selected_item progress_filled progress_empty \
        lyrics_played lyrics_current lyrics_upcoming active_tab inactive_tab

    if test "$mode" = dawn
        set ytm_theme_name rose-pine-dawn
        set playback_bar_bg "#fffaf3"; set selected_item "#f2e9e1"
        set progress_filled "#b4637a"; set progress_empty "#f2e9e1"
        set lyrics_played "#9893a5"; set lyrics_current "#907aa9"; set lyrics_upcoming "#575279"
        set active_tab "#faf4ed"; set inactive_tab "#f2e9e1"
    else
        set ytm_theme_name rose-pine-moon
        set playback_bar_bg "#2a273f"; set selected_item "#393552"
        set progress_filled "#eb6f92"; set progress_empty "#393552"
        set lyrics_played "#6e6a86"; set lyrics_current "#c4a7e7"; set lyrics_upcoming "#c8c8e5"
        set active_tab "#232136"; set inactive_tab "#393552"
    end

    sed -i "s/^theme = \".*\"/theme = \"$ytm_theme_name\"/" $YTM_CONFIG
    for key in playback_bar_bg selected_item progress_filled progress_empty \
        lyrics_played lyrics_current lyrics_upcoming active_tab inactive_tab
        set val $$key
        set pat (string join '' $key '[[:space:]]*=[[:space:]]*')
        sed -i "s/^\($pat\).*/\1\"$val\"/" $YTM_THEME
    end
end

function apply_gtk
    set theme $argv[1]
    set dir (path filter -d $HOME/.themes/$theme /usr/share/themes/$theme | head -1)
    test -z "$dir"; and return 1
    sed -i "s/^gtk-theme-name=.*/gtk-theme-name=$theme/" $HOME/.config/gtk-3.0/settings.ini $HOME/.config/gtk-4.0/settings.ini
    ln -sf $dir/gtk-4.0/gtk.css $HOME/.config/gtk-4.0/gtk.css
    ln -sf $dir/gtk-4.0/gtk-dark.css $HOME/.config/gtk-4.0/gtk-dark.css
    ln -sfn $dir/gtk-4.0/assets $HOME/.config/gtk-4.0/assets
    sed -i "s|^Net/ThemeName .*|Net/ThemeName \"$theme\"|" $HOME/.config/xsettingsd/xsettingsd.conf
    pkill -HUP xsettingsd 2>/dev/null
end

function apply_night
    cp $NIGHT_CSS $ACTIVE_CSS
    echo night >$MODE_FILE
    sed -i 's|import = \["~/.config/alacritty/.*\.toml"\]|import = ["~/.config/alacritty/rose-pine-moon.toml"]|' $ALACRITTY_TOML
    sed -i 's|^include rose-pine-.*.conf|include rose-pine-moon.conf|' $KITTY_CONF
    sed -i 's|source ~/.config/fish/themes/fzf-.*.fish|source ~/.config/fish/themes/fzf-moon.fish|' $FISH_CONFIG
    sed -i 's/colorscheme rosepine.*/colorscheme rosepine_moon/' $VIMRC
    sed -i 's/set background=.*/set background=dark/' $VIMRC
    sed -i 's|source ~/.vim/themes/statusline-.*.vim|source ~/.vim/themes/statusline-moon.vim|' $VIMRC
    sed -i 's/background = #.*/background = #232136/' $IMV_CONFIG
    sed -i 's/overlay_background_color = #.*/overlay_background_color = #f6c177/' $IMV_CONFIG
    sed -i 's/overlay_text_color = #.*/overlay_text_color = #232136/' $IMV_CONFIG
    sed -i 's|^@theme ".*"|@theme "/home/ahloi/.local/share/rofi/themes/Rose-pine-moon-square-centered.rasi"|' $ROFI_CONFIG
    sed -i 's/--theme=.*/--theme="Rose-Pine-Moon"/' $HOME/.config/bat/config
    sed -i 's/NNN_BATTHEME:-[^}]*/NNN_BATTHEME:-Rose-Pine-Moon/' $HOME/.config/nnn/plugins/preview-tui
    sed -i 's|color_scheme_path=.*|color_scheme_path=/usr/share/qt6ct/colors/rose-pine.conf|' $HOME/.config/qt6ct/qt6ct.conf
    sed -i 's|rosepine-dawn\.qss|rosepine.qss|' $HOME/.config/qt6ct/qt6ct.conf
    sed -i 's|krita-icon-fix-dawn\.qss|krita-icon-fix.qss|' $HOME/.config/qt6ct/qt6ct.conf
    sed -i 's/xcursor_theme BreezeX-.*/xcursor_theme BreezeX-RosePine-Linux 24/' $HOME/.config/scroll/config
    gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
    gsettings set org.gnome.desktop.interface gtk-theme "Rosepine-Red-Dark-Moon"
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    apply_gtk Rosepine-Red-Dark-Moon
    set -Ux NNN_BATTHEME Rose-Pine-Moon
    source ~/.config/fish/themes/colors-moon.fish
    sed -i "s/@rose_pine_variant '.*/@rose_pine_variant 'moon'/" $TMUX_CONF
    sed -i "s/theme = '.*/theme = 'moon'/" ~/.config/cava/config
    tmux source $TMUX_CONF 2>/dev/null
    sed -i 's/icon_theme = .*/icon_theme = Papirus-Dark/' $DUNSTRC
    sed -i 's/frame_color = "#.*"/frame_color = "#eb6f92"/' $DUNSTRC
    sed -i '/^\[urgency_low\]/,/^\[/ s/background = "#.*"/background = "#232136"/' $DUNSTRC
    sed -i '/^\[urgency_low\]/,/^\[/ s/foreground = "#.*"/foreground = "#c8c8e5"/' $DUNSTRC
    sed -i '/^\[urgency_normal\]/,/^\[/ s/background = "#.*"/background = "#232136"/' $DUNSTRC
    sed -i '/^\[urgency_normal\]/,/^\[/ s/foreground = "#.*"/foreground = "#c8c8e5"/' $DUNSTRC
    sed -i '/^\[urgency_critical\]/,/^\[/ s/background = "#.*"/background = "#eb6f92"/' $DUNSTRC
    sed -i '/^\[urgency_critical\]/,/^\[/ s/foreground = "#.*"/foreground = "#c8c8e5"/' $DUNSTRC
    sed -i '/^\[urgency_critical\]/,/^\[/ s/frame_color = "#.*"/frame_color = "#232136"/' $DUNSTRC
    apply_ytm_theme moon
    pkill -9 -x dunst; sleep 0.3; dunst &disown
    scrollmsg reload
    sleep 0.3
    wallpaper $HOME/Pictures/thinkpad.png
    scrollmsg "client.focused #232136 #232136 #c8c8e5 #44415a #232136"
    scrollmsg "client.focused_inactive #232136 #232136 #6e6a86 #232136 #232136"
    scrollmsg "client.unfocused #232136 #232136 #6e6a86 #232136 #232136"
    scrollmsg "client.background #232136"
    notify-send -t 1500 "Waybar" "Night mode on" 2>/dev/null
end

function apply_dawn
    cp $DAWN_CSS $ACTIVE_CSS
    echo dawn >$MODE_FILE
    sed -i 's|import = \["~/.config/alacritty/.*\.toml"\]|import = ["~/.config/alacritty/rose-pine-dawn.toml"]|' $ALACRITTY_TOML
    sed -i 's|^include rose-pine-.*.conf|include rose-pine-dawn.conf|' $KITTY_CONF
    sed -i 's|source ~/.config/fish/themes/fzf-.*.fish|source ~/.config/fish/themes/fzf-dawn.fish|' $FISH_CONFIG
    sed -i 's/colorscheme rosepine.*/colorscheme rosepine_dawn/' $VIMRC
    sed -i 's/set background=.*/set background=light/' $VIMRC
    sed -i 's|source ~/.vim/themes/statusline-.*.vim|source ~/.vim/themes/statusline-dawn.vim|' $VIMRC
    sed -i 's/background = #.*/background = #faf4ed/' $IMV_CONFIG
    sed -i 's/overlay_background_color = #.*/overlay_background_color = #ea9d34/' $IMV_CONFIG
    sed -i 's/overlay_text_color = #.*/overlay_text_color = #faf4ed/' $IMV_CONFIG
    sed -i 's|^@theme ".*"|@theme "/home/ahloi/.local/share/rofi/themes/Rose-pine-dawn-square-centered.rasi"|' $ROFI_CONFIG
    sed -i 's/--theme=.*/--theme="Rose-Pine-Dawn"/' $HOME/.config/bat/config
    sed -i 's/NNN_BATTHEME:-[^}]*/NNN_BATTHEME:-Rose-Pine-Dawn/' $HOME/.config/nnn/plugins/preview-tui
    sed -i 's|color_scheme_path=.*|color_scheme_path=/home/ahloi/.config/qt6ct/colors/rosepine-dawn.conf|' $HOME/.config/qt6ct/qt6ct.conf
    sed -i 's|rosepine\.qss|rosepine-dawn.qss|' $HOME/.config/qt6ct/qt6ct.conf
    sed -i 's|krita-icon-fix\.qss|krita-icon-fix-dawn.qss|' $HOME/.config/qt6ct/qt6ct.conf
    sed -i 's/xcursor_theme BreezeX-.*/xcursor_theme BreezeX-RosePineDawn-Linux 24/' $HOME/.config/scroll/config
    gsettings set org.gnome.desktop.interface gtk-theme "Rosepine-Pink-Light"
    gsettings set org.gnome.desktop.interface color-scheme prefer-light
    apply_gtk Rosepine-Pink-Light
    gsettings set org.gnome.desktop.interface icon-theme "Papirus-Light"
    set -Ux NNN_BATTHEME Rose-Pine-Dawn
    source ~/.config/fish/themes/colors-dawn.fish
    sed -i "s/@rose_pine_variant '.*/@rose_pine_variant 'dawn'/" $TMUX_CONF
    sed -i "s/theme = '.*/theme = 'dawn'/" ~/.config/cava/config
    tmux source $TMUX_CONF 2>/dev/null
    sed -i 's/icon_theme = .*/icon_theme = Papirus-Light/' $DUNSTRC
    sed -i 's/frame_color = "#.*"/frame_color = "#907aa9"/' $DUNSTRC
    sed -i '/^\[urgency_low\]/,/^\[/ s/background = "#.*"/background = "#faf4ed"/' $DUNSTRC
    sed -i '/^\[urgency_low\]/,/^\[/ s/foreground = "#.*"/foreground = "#575279"/' $DUNSTRC
    sed -i '/^\[urgency_normal\]/,/^\[/ s/background = "#.*"/background = "#faf4ed"/' $DUNSTRC
    sed -i '/^\[urgency_normal\]/,/^\[/ s/foreground = "#.*"/foreground = "#575279"/' $DUNSTRC
    sed -i '/^\[urgency_critical\]/,/^\[/ s/background = "#.*"/background = "#b4637a"/' $DUNSTRC
    sed -i '/^\[urgency_critical\]/,/^\[/ s/foreground = "#.*"/foreground = "#faf4ed"/' $DUNSTRC
    sed -i '/^\[urgency_critical\]/,/^\[/ s/frame_color = "#.*"/frame_color = "#faf4ed"/' $DUNSTRC
    apply_ytm_theme dawn
    pkill -9 -x dunst; sleep 0.3; dunst &disown
    scrollmsg reload
    sleep 0.3
    wallpaper $HOME/Pictures/Bicycle.jpg
    scrollmsg "client.focused #dfdad9 #907aa9 #5a3e8a #cecacd #dfdad9"
    scrollmsg "client.focused_inactive #dfdad9 #d7827e #8f4f4c #dfdad9 #dfdad9"
    scrollmsg "client.unfocused #dfdad9 #d7827e #8f4f4c #dfdad9 #dfdad9"
    scrollmsg "client.background #faf4ed"
    notify-send -t 1500 "Waybar" "Dawn mode on" 2>/dev/null
end

function apply_day
    cp $DAY_CSS $ACTIVE_CSS
    echo day >$MODE_FILE
    sed -i 's|import = \["~/.config/alacritty/.*\.toml"\]|import = ["~/.config/alacritty/rose-pine-moon.toml"]|' $ALACRITTY_TOML
    sed -i 's|^include rose-pine-.*.conf|include rose-pine-moon.conf|' $KITTY_CONF
    sed -i 's|source ~/.config/fish/themes/fzf-.*.fish|source ~/.config/fish/themes/fzf-moon.fish|' $FISH_CONFIG
    sed -i 's/colorscheme rosepine.*/colorscheme rosepine_moon/' $VIMRC
    sed -i 's/set background=.*/set background=dark/' $VIMRC
    sed -i 's|source ~/.vim/themes/statusline-.*.vim|source ~/.vim/themes/statusline-moon.vim|' $VIMRC
    sed -i 's/background = #.*/background = #232136/' $IMV_CONFIG
    sed -i 's/overlay_background_color = #.*/overlay_background_color = #f6c177/' $IMV_CONFIG
    sed -i 's/overlay_text_color = #.*/overlay_text_color = #232136/' $IMV_CONFIG
    sed -i 's|^@theme ".*"|@theme "/home/ahloi/.local/share/rofi/themes/Rose-pine-moon-square-centered.rasi"|' $ROFI_CONFIG
    sed -i 's/--theme=.*/--theme="Rose-Pine-Moon"/' $HOME/.config/bat/config
    sed -i 's/NNN_BATTHEME:-[^}]*/NNN_BATTHEME:-Rose-Pine-Moon/' $HOME/.config/nnn/plugins/preview-tui
    sed -i 's|color_scheme_path=.*|color_scheme_path=/usr/share/qt6ct/colors/rose-pine.conf|' $HOME/.config/qt6ct/qt6ct.conf
    sed -i 's|rosepine-dawn\.qss|rosepine.qss|' $HOME/.config/qt6ct/qt6ct.conf
    sed -i 's|krita-icon-fix-dawn\.qss|krita-icon-fix.qss|' $HOME/.config/qt6ct/qt6ct.conf
    sed -i 's/xcursor_theme BreezeX-.*/xcursor_theme BreezeX-RosePine-Linux 24/' $HOME/.config/scroll/config
    gsettings set org.gnome.desktop.interface gtk-theme "Rosepine-Red-Dark-Moon"
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    apply_gtk Rosepine-Red-Dark-Moon
    gsettings set org.gnome.desktop.interface icon-theme "Papirus"
    set -Ux NNN_BATTHEME Rose-Pine-Moon
    source ~/.config/fish/themes/colors-moon.fish
    sed -i "s/@rose_pine_variant '.*/@rose_pine_variant 'moon'/" $TMUX_CONF
    sed -i "s/theme = '.*/theme = 'moon'/" ~/.config/cava/config
    tmux source $TMUX_CONF 2>/dev/null
    sed -i 's/icon_theme = .*/icon_theme = Papirus/' $DUNSTRC
    sed -i 's/frame_color = "#.*"/frame_color = "#eb6f92"/' $DUNSTRC
    sed -i '/^\[urgency_low\]/,/^\[/ s/background = "#.*"/background = "#232136"/' $DUNSTRC
    sed -i '/^\[urgency_low\]/,/^\[/ s/foreground = "#.*"/foreground = "#c8c8e5"/' $DUNSTRC
    sed -i '/^\[urgency_normal\]/,/^\[/ s/background = "#.*"/background = "#232136"/' $DUNSTRC
    sed -i '/^\[urgency_normal\]/,/^\[/ s/foreground = "#.*"/foreground = "#c8c8e5"/' $DUNSTRC
    sed -i '/^\[urgency_critical\]/,/^\[/ s/background = "#.*"/background = "#eb6f92"/' $DUNSTRC
    sed -i '/^\[urgency_critical\]/,/^\[/ s/foreground = "#.*"/foreground = "#c8c8e5"/' $DUNSTRC
    sed -i '/^\[urgency_critical\]/,/^\[/ s/frame_color = "#.*"/frame_color = "#232136"/' $DUNSTRC
    apply_ytm_theme moon
    pkill -9 -x dunst; sleep 0.3; dunst &disown
    scrollmsg reload
    sleep 0.3
    wallpaper $HOME/Pictures/Bicycle.jpg
    scrollmsg "client.focused #232136 #c4a7e7 #7550a5 #f6c177 #232136"
    scrollmsg "client.focused_inactive #232136 #ea9a97 #a05550 #232136 #232136"
    scrollmsg "client.unfocused #232136 #ea9a97 #a05550 #232136 #232136"
    scrollmsg "client.background #232136"
    notify-send -t 1500 "Waybar" "Day mode on" 2>/dev/null
end

set choice (printf "day\nnight\ndawn\n" | fzf --prompt="Theme > " --header="Select waybar mode")
test -z "$choice"; and exit 1

switch $choice
    case day
        apply_day
    case night
        apply_night
    case dawn
        apply_dawn
end

pkill -SIGUSR2 waybar
