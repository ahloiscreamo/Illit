# Sway/Scroll Environment Variables
# Tell QT, GDK and others to use the Wayland backend by default, X11 if not available
set -gx QT_QPA_PLATFORM "wayland;xcb"
set -gx GDK_BACKEND "wayland,x11"
set -gx SDL_VIDEODRIVER wayland
set -gx CLUTTER_BACKEND wayland

# XDG desktop variables to set scroll as the desktop
set -gx XDG_CURRENT_DESKTOP scroll
set -gx XDG_SESSION_TYPE wayland
set -gx XDG_SESSION_DESKTOP scroll

# Configure Electron to use Wayland instead of X11
set -gx ELECTRON_OZONE_PLATFORM_HINT wayland

set -gx QT_WAYLAND_DISABLE_WINDOWDECORATION 1 # Disables window decorations on Qt applications
set -gx QT_QPA_PLATFORMTHEME qt6ct
# This is to (temporarily) fix font rendering on QWebEngineView 6
# (qutebrowser, goldendict etc.)
# https://bugreports.qt.io/browse/QTBUG-113574
set -gx QT_SCALE_FACTOR_ROUNDING_POLICY RoundPreferFloor

# Ueberzug
set -gx UEBERZUG_LAYER_BACKEND wayland

# Gtk theme
set -gx GTK_THEME "Rosepine-Red-Dark-Moon"

# Ueberzugpp Wayland config
echo '{
  "layer": {
    "silent": true,
    "use-escape-codes": false,
    "output": "wayland",
    "origin-center": true
  }
}' > ~/.config/ueberzugpp/config.json
