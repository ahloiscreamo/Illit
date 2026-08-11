# Configuration to run in interactive sessions
if status is-interactive
    # Removes the initial greeting message
    set -U fish_greeting
end

# D-Bus session bus
if not set -q DBUS_SESSION_BUS_ADDRESS
    if test -S /run/user/(id -u)/bus
        set -gx DBUS_SESSION_BUS_ADDRESS unix:path=/run/user/(id -u)/bus
    else
        set -gx DBUS_SESSION_BUS_ADDRESS (dbus-launch --sh-syntax | string match -r "(?<=')[^']+(?=')" | head -1)
    end
end

# === NNN Environment Variables (Kept as 'export' for compatibility) ===

export NNN_FIFO="/tmp/nnn.fifo"
export NNN_PREVIEW="/tmp/nnn-preview-tui-fifopid."
set -gx NNN_VIDEPREVIEW 1 #Disable line for static video preview

# Smart Kitty Detection for NNN Previews
if test "$TERM" = "xterm-kitty" -o -n "$KITTY_WINDOW_ID"
    # Unset so nnn's preview-tui auto-detects Kitty and uses native icat rendering
    set -e NNN_PREVIEWIMGPROG
else
    # Fallback to viu for other terminals
    set -gx NNN_PREVIEWIMGPROG "viu -w 90"
end

#export NNN_OPENER="xdg-open"
export NNN_OPENER="/home/ahloi/.config/nnn/plugins/nuke"
export GUI=1
export NNN_OPENER_DETACH=1
export NNN_COLORS="56324170"
export NNN_FCOLORS="0B0405020006060009060B01"
export NNN_BMS='m:/mnt;g:/mnt/Kingston/gallery-dl/instagram;d:~/Downloads;p:~/Pictures;t:~/Documents;f:~/Desktop'
export NNN_PLUG='a:addtoplaylist;j:autojump;p:preview-tui;l:launch;r:renamer;o:fzopen;c:fzcd;x:xdgdefault'

# === Global Variables (using 'set -gx' for export) ===

# Clifm
set -gx CLIFM_PROMPT_P_MAX_PATH "40"

# Github-Cli
set -gx GLAMOUR_STYLE ".config/glamour/rose-pine.json"

# Editor (Kept your original export as well for maximum compatibility, but using set -gx for the others)
set -gx EDITOR "vim"
set -gx VISUAL "vim"

# Qt6ct
set -gx QT_QPA_PLATFORMTHEME "qt6ct"

# fex
# Source .fex.fish if it's present
[ -f ~/.fex.fish ] && source ~/.fex.fish

# Bind SUPER-F to invoke fex (key binds can be custom)
bind \super-f fex-widget

# fzf
source ~/.config/fish/themes/fzf-moon.fish

# Firefox
set -gx MOZ_X11_EGL "1"

# Kunst
set -gx KUNST_SIZE "280x280"
set -gx KUNST_MUSIC_DIR "/mnt/Kingston/Music"

# Font Preview
set -gx FONTPREVIEW_SEARCH_PROMPT "❯ "
set -gx FONTPREVIEW_SIZE 532x365
set -gx FONTPREVIEW_POSITION "+0+0"
set -gx FONTPREVIEW_FONT_SIZE 38
set -gx FONTPREVIEW_BG_COLOR "#ffffff"
set -gx FONTPREVIEW_FG_COLOR "#000000"
set -gx FONTPREVIEW_PREVIEW_TEXT "ABCDEFGHIJKLM\nNOPQRSTUVWXYZ\nabcdefghijklm\nnopqrstuvwxyz\n1234567890\n!@\%(){}[]"

# fff
set -gx FFF_W3M_XOFFSET 27
set -gx FFF_W3M_YOFFSET 13
set -gx FFF_OPENER "xdg-open"
set -gx FFF_LS_COLORS 1
set -gx FFF_COL1 5
set -gx FFF_COL2 6
set -gx FFF_COL3 3
set -gx FFF_COL4 1
set -gx FFF_COL5 0

# Gemini API
set -gx GEMINI_API_KEY "AIzaSyBdgtnEh_SI_9Dnkre3zLaPAuq162-Dal0"

# === PATH Modifications (use fish_add_path) ===

# Npm, Pipx, and Cargo are now added safely and idempotently, removing colon-separated PATH commands
fish_add_path ~/.npm-global/bin
fish_add_path ~/.local/bin
fish_add_path $HOME/.cargo/bin

# === Aliases and Functions ===

alias bat="bat --italic-text always --force-colorization --style full"
alias chawan="env COLORTERM=truecolor chawan"
alias clx="clx -n"
alias cal="cmus-auto-lyrics -a -s "L3fR9dfGNk41wog1uHpHeF8-JCh1HTz48SLi4B0LpaCenhQbIiORQmUgFF01khwT""
alias chafa="chafa --stretch none"
alias fex "fex --time-type modified"
alias mocp="mocp -C ~/.config/moc/config"
alias nnn="nnn -c -r -e -D"
alias icat="kitty +kitten icat"
alias record='wf-recorder -f ~/Videos/recording-(date +%Y%m%d-%H%M%S).mp4 -c libx264 -r 60 -x yuv420p --filter "scale=out_color_matrix=bt709:out_range=full" -p color_range=jpeg -p colorspace=bt709 -p color_trc=iec61966-2-1 -p color_primaries=bt709'
alias record-window='wf-recorder -f ~/Videos/recording-$(date +%Y%m%d-%H%M%S).mp4 -c libx264 -r 60 -x yuv420p --filter "scale=out_color_matrix=bt709:out_range=full" -p color_range=jpeg -p colorspace=bt709 -p color_trc=iec61966-2-1 -p color_primaries=bt709 -g "$(slurp)"'
alias kitty="kitty --single-instance"
alias w3m="w3m -o inline_img_protocol=4"
alias ls="eza --icons --group-directories-first -s=type"
alias ncdu="ncdu --color dark"
alias archwiki-offline="archwiki-offline -o w3m -m fzf"
alias archwiki="archwiki-offline"
alias ffind="find ~ -type f | fzf --preview 'fzf-preview.sh {}' --bind 'enter:execute(vim {})' --bind 'focus:transform-header:file --brief {}'"
alias preview="fzf --preview 'file {}' | xargs -d '\n' xdg-open"
alias muc="muc --file ~/.local/share/fish/fish_history --count 10 --pretty --shell=\"fish\""
alias tap="tap -db --color fg=c8c8e5,bg=232136,hl=c4a7e7,prompt=3e8fb0,header=ea9a97,header+=eb6f92,progress=f6c177,info=3e8fb0,err=eb6f92"
alias tether-stop-charge="adb shell dumpsys battery set status 3"
alias tether-reset-charge="adb shell dumpsys battery reset"

# === Sourcing Other Files/Tools ===

# Function to launch ddgr and force it to use w3m
function ddgr
        env DDGR_EXCLUSIVE_BROWSER=w3m ddgr $argv
end

# Function to launch reddix and force it to use surf for opening links
function reddix
    env BROWSER=launch-nsxiv reddix $argv
end

# Ensure global BROWSER is unset to favor xdg-open
set -e BROWSER

# Set up fzf key bindings (must be run *after* FZF_DEFAULT_OPTS is set)
fzf --fish | source

# Icons_in_terminal
source ~/.local/share/icons-in-terminal/icons.fish

# Starship (https://github.com/starship/starship)
starship init fish | source

# === Fish Color Settings (Universal) ===

#set -U fish_color_command 9ccfd8
#set -U fish_color_match --background=blue
#set -U fish_color_user green

# === Zoxide  ===
zoxide init fish | source

# Ueberzugpp default config (X11)
echo '{
  "layer": {
    "silent": true,
    "use-escape-codes": false,
    "output": "x11"
  }
}' > ~/.config/ueberzugpp/config.json

# If this is a Wayland session, source the Wayland-specific settings to override defaults.
if test "$XDG_SESSION_TYPE" = "wayland"
    if test -f ~/.config/fish/wayland.fish
        source ~/.config/fish/wayland.fish
    end
end
