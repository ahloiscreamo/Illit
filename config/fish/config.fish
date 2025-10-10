# Configuration to run in interactive sessions
if status is-interactive
    # Removes the initial greeting message
    set -U fish_greeting
end

# === NNN Environment Variables (Kept as 'export' for compatibility) ===

export NNN_FIFO="/tmp/nnn.fifo"
export NNN_PREVIEW="/tmp/nnn-preview-tui-fifopid."
export NNN_OPENER="xdg-open"
export NNN_OPENER_DETACH=1
export NNN_COLORS="5632"
export NNN_FCOLORS="0B0405020006060009060B01"
export NNN_BMS='m:/mnt;g:/mnt/Kingston/gallery-dl/instagram;d:~/Downloads;p:~/Pictures;t:~/Documents;f:~/Desktop'
export NNN_PLUG='a:addtoplaylist;j:autojump;p:preview-tui;l:launch;r:renamer;o:fzopen;c:fzcd;x:xdgdefault'

# === Global Variables (using 'set -gx' for export) ===

# Editor (Kept your original export as well for maximum compatibility, but using set -gx for the others)
set -gx EDITOR "vim"
set -gx VISUAL "vim"

# Qt5ct
set -gx QT_QPA_PLATFORMTHEME "qt5ct"

# fzf
# Define FZF_DEFAULT_OPTS once
set -gx FZF_DEFAULT_OPTS '
  --color=fg:#c8c8e5,fg+:#c8c8e5,bg:#232136,bg+:#393552
  --color=hl:#3e8fb0,hl+:#9ccfd8,info:#f6c177,marker:#f6c177
  --color=prompt:#eb6f92,spinner:#c4a7e7,pointer:#c4a7e7,header:#9ccfd8
  --color=border:#393552,label:#44415a,query:#6e6a86
  --border="rounded" --border-label="" --preview-window="noborder" --prompt="> "
  --marker=">" --pointer="◆" --separator="─" --scrollbar="│"'

# yt-x FZF Options (Extends defaults and only overrides specific colours/settings)
set -gx YT_X_FZF_OPTS $FZF_DEFAULT_OPTS'
  --color=bg+:#44415a
  --color=marker:#3e8fb0
  --color=header:#3e8fb0
  --color=border:#44415a
  --color=label:#ea9a97
  --color=query:#f6c177
  --preview-window="border-rounded"'
  
# Bat
set -gx BAT_THEME "Rose-Pine-Moon"

# Mangal
set -gx MANGAL_FORMATS_USE "cbz"
set -gx MANGAL_DOWNLOADER_CREATE_VOLUME_DIR "true"

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
alias clx="clx -n"
alias magic="magic-tape.sh"
alias nnn="nnn -r -e -x"
alias icat="kitty +kitten icat"
alias w3m="w3m -o inline_img_protocol=4"
alias ls="eza --icons --group-directories-first -s=type"
alias ncdu="ncdu --color dark"
alias archwiki-offline="archwiki-offline -o w3m -m fzf"
alias archwiki="archwiki-offline"
alias muc="muc --file ~/.local/share/fish/fish_history --count 10 --pretty --shell=\"fish\""
alias tap="tap -db --color fg=c8c8e5,bg=232136,hl=c4a7e7,prompt=3e8fb0,header=ea9a97,header+=eb6f92,progress=f6c177,info=3e8fb0,err=eb6f92"


# === Sourcing Other Files/Tools ===

# Function to launch ddgr and force it to use w3m
function ddgr
        env DDGR_EXCLUSIVE_BROWSER=w3m ddgr $argv
end

# Set up fzf key bindings (must be run *after* FZF_DEFAULT_OPTS is set)
fzf --fish | source

# Icons_in_terminal
source ~/.local/share/icons-in-terminal/icons.fish

# Starship (https://github.com/starship/starship)
starship init fish | source

# === Fish Color Settings (Universal) ===

set -U fish_color_command 9ccfd8
set -U fish_color_match --background=blue
set -U fish_color_user green
