-- ~/.config/swayimg/init.lua
--
-- Create the dir first if it doesn't exist:
--   mkdir -p ~/.config/swayimg
-- then save this as ~/.config/swayimg/init.lua

------------------------------------------------------------
-- Window behaviour
------------------------------------------------------------

-- Sway/Hyprland-only "overlay" mode is ON by default under Sway
-- (and scroll is a sway fork, so it inherits this). Overlay makes
-- swayimg spawn a floating window sized/positioned to match your
-- currently focused terminal -- that's the "opens inside the
-- terminal" behavior you don't want. Turn it off so it opens as a
-- normal window that scroll tiles/scrolls like anything else.
swayimg.overlay = false

-- No client-side titlebar/border -- let scroll draw window
-- decoration the same way it does for every other app.
swayimg.decoration = false

-- Explicit appid, useful if you ever want a for_window rule for it
-- in your scroll/sway config (app_id="swayimg").
swayimg.appid = "swayimg"

-- Always queue up every image in the same directory,
-- whether swayimg was launched on one file or a whole folder.
swayimg.imagelist.adjacent = true

------------------------------------------------------------
-- Theme mode: read the same mode file your waybar day/night/dawn
-- toggle script writes to, so swayimg follows it automatically.
-- The toggle script's "day" and "night" states both apply the dark
-- Rosé Pine Moon palette (they only differ by wallpaper); only
-- "dawn" applies the light Rosé Pine Dawn palette. We mirror that
-- here. NOTE: this is read once at startup -- a swayimg window
-- already open won't re-theme itself when you toggle; only windows
-- opened after the toggle will pick up the new palette (same as
-- how alacritty/vim behave in that script).
------------------------------------------------------------

local function read_mode()
  local path = os.getenv("HOME") .. "/.config/waybar/.mode"
  local f = io.open(path, "r")
  if not f then return "day" end
  local mode = f:read("*l")
  f:close()
  return mode or "day"
end

local function with_alpha(color, alpha)
  -- Lua 5.3+ bitwise ops (<<, &) aren't available in swayimg's
  -- embedded Lua, so do this with plain arithmetic instead.
  return alpha * 0x1000000 + (color % 0x1000000)
end

local palettes = {
  -- Rosé Pine Moon (dark)
  moon = {
    base    = 0xff232136,
    surface = 0xff2a273f,
    overlay = 0xff393552,
    text    = 0xffe0def4,
    love    = 0xffeb6f92,
    gold    = 0xfff6c177,
    iris    = 0xffc4a7e7,
    hl_med  = 0xff44415a,
  },
  -- Rosé Pine Dawn (light)
  dawn = {
    base    = 0xfffaf4ed,
    surface = 0xfffffaf3,
    overlay = 0xfff2e9e1,
    text    = 0xff575279,
    love    = 0xffb4637a,
    gold    = 0xffea9d34,
    iris    = 0xff907aa9,
    hl_med  = 0xffdfdad9,
  },
}

local mode = read_mode()
local palette = (mode == "dawn") and palettes.dawn or palettes.moon

local rp_base    = palette.base
local rp_surface = palette.surface
local rp_overlay = palette.overlay
local rp_text    = palette.text
local rp_love    = palette.love
local rp_gold    = palette.gold
local rp_iris    = palette.iris
local rp_hl_med  = palette.hl_med

------------------------------------------------------------
-- Text layer (the "bar" -- filename/index/status overlay)
------------------------------------------------------------

swayimg.text.font = "Maple Mono NF CN"
swayimg.text.size = 14
swayimg.text.padding = 12

swayimg.text.color = with_alpha(rp_text, 0xff)
swayimg.text.background = with_alpha(rp_surface, 0xcc) -- surface, semi-transparent
swayimg.text.shadow = 0x00000000                        -- shadow off, bg already gives contrast

------------------------------------------------------------
-- Keep the text layer hidden until toggled with 't'
------------------------------------------------------------
swayimg.on_initialized(function()
  swayimg.text.visible = false
end)

------------------------------------------------------------
-- Viewer & slideshow: window/image colors
------------------------------------------------------------

swayimg.viewer.set_window_background(rp_base)
swayimg.viewer.set_image_chessboard(16, rp_surface, rp_overlay) -- transparency checker, themed
swayimg.viewer.mark_color = rp_gold

swayimg.slideshow.set_window_background(rp_base)
swayimg.slideshow.set_image_chessboard(16, rp_surface, rp_overlay)
swayimg.slideshow.mark_color = rp_gold

------------------------------------------------------------
-- Adjustable slideshow delay ([ decreases, ] increases)
------------------------------------------------------------
local slideshow_delay = 5 -- starting value, seconds

swayimg.slideshow.timeout = slideshow_delay

swayimg.slideshow.on_key("]", function()
  slideshow_delay = slideshow_delay + 1
  swayimg.slideshow.timeout = slideshow_delay
  swayimg.text.set_status("Slideshow delay: " .. slideshow_delay .. "s")
end)

swayimg.slideshow.on_key("[", function()
  slideshow_delay = math.max(1, slideshow_delay - 1)
  swayimg.slideshow.timeout = slideshow_delay
  swayimg.text.set_status("Slideshow delay: " .. slideshow_delay .. "s")
end)

------------------------------------------------------------
-- Gallery mode: window/thumbnail colors
------------------------------------------------------------

swayimg.gallery.window_color = rp_base
swayimg.gallery.unselected_color = rp_surface
swayimg.gallery.selected_color = rp_hl_med
swayimg.gallery.border_color = rp_iris
swayimg.gallery.border_size = 3
swayimg.gallery.mark_color = rp_gold

------------------------------------------------------------
-- Restore picture height on start (viewer + slideshow)
------------------------------------------------------------
swayimg.on_window_resize(function()
  local m = swayimg.mode
  if m == "viewer" then
    swayimg.viewer.set_fix_scale("optimal")
  elseif m == "slideshow" then
    swayimg.slideshow.set_fix_scale("optimal")
  end
end)

------------------------------------------------------------
-- Vim-style keys (nsxiv/sxiv parity)
------------------------------------------------------------

local PAN_STEP = 60

-- Panning with hjkl in viewer mode. Direction is: h=left, l=right,
-- k=up, j=down (mirrors nsxiv). If this feels reversed on your
-- system, flip the sign (- to + or vice versa) on the two lines
-- inside pan_viewer().
local function pan_viewer(dx, dy)
  local pos = swayimg.viewer.get_position()
  swayimg.viewer.set_abs_position(pos.x - dx, pos.y - dy)
end

swayimg.viewer.on_key("h", function() pan_viewer(-PAN_STEP, 0) end)
swayimg.viewer.on_key("l", function() pan_viewer(PAN_STEP, 0) end)
swayimg.viewer.on_key("k", function() pan_viewer(0, -PAN_STEP) end)
swayimg.viewer.on_key("j", function() pan_viewer(0, PAN_STEP) end)

-- g / G: first / last image (viewer + slideshow + gallery)
-- NOTE: viewer.switch_image()/slideshow.switch_image() are deprecated
-- in favor of .open(); gallery.switch_image() is deprecated in favor
-- of .select() -- all just renamed calls, same string arguments.
swayimg.viewer.on_key("g", function() swayimg.viewer.open("first") end)
swayimg.viewer.on_key("Shift-g", function() swayimg.viewer.open("last") end)
swayimg.slideshow.on_key("g", function() swayimg.slideshow.open("first") end)
swayimg.slideshow.on_key("Shift-g", function() swayimg.slideshow.open("last") end)
swayimg.gallery.on_key("g", function() swayimg.gallery.select("first") end)
swayimg.gallery.on_key("Shift-g", function() swayimg.gallery.select("last") end)

-- n / p: next / previous image (nsxiv-style alias for PgDown/PgUp)
swayimg.viewer.on_key("n", function() swayimg.viewer.open("next") end)
swayimg.viewer.on_key("p", function() swayimg.viewer.open("prev") end)

-- hjkl grid navigation in gallery (mirrors nsxiv thumbnail mode)
swayimg.gallery.on_key("h", function() swayimg.gallery.select("left") end)
swayimg.gallery.on_key("l", function() swayimg.gallery.select("right") end)
swayimg.gallery.on_key("k", function() swayimg.gallery.select("up") end)
swayimg.gallery.on_key("j", function() swayimg.gallery.select("down") end)

-- q: quit everywhere (default is Esc only)
swayimg.viewer.on_key("q", function() swayimg.exit() end)
swayimg.slideshow.on_key("q", function() swayimg.exit() end)
swayimg.gallery.on_key("q", function() swayimg.exit() end)

-- r: reload (nsxiv default, swayimg has no key for it by default)
swayimg.viewer.on_key("r", function() swayimg.viewer.reload() end)
swayimg.gallery.on_key("r", function() swayimg.gallery.reload() end)

-- 0 / w: real size / fit to window (nsxiv-style zoom shortcuts)
swayimg.viewer.on_key("0", function() swayimg.viewer.set_fix_scale("real") end)
swayimg.viewer.on_key("Shift-w", function() swayimg.viewer.set_fix_scale("fit") end)
swayimg.viewer.on_key("w", function() swayimg.viewer.set_fix_scale("width") end)
