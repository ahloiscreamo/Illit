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
swayimg.enable_overlay(false)

-- No client-side titlebar/border -- let scroll draw window
-- decoration the same way it does for every other app.
swayimg.enable_decoration(false)

-- Explicit appid, useful if you ever want a for_window rule for it
-- in your scroll/sway config (app_id="swayimg").
swayimg.set_appid("swayimg")

-- Always queue up every image in the same directory,
-- whether swayimg was launched on one file or a whole folder.
swayimg.imagelist.enable_adjacent(true)

------------------------------------------------------------
-- Text layer (the "bar" -- filename/index/status overlay)
------------------------------------------------------------

swayimg.text.set_font("Maple Mono NF CN")
swayimg.text.set_size(14)
swayimg.text.set_padding(12)

-- Rosé Pine Moon: text=#e0def4, surface=#2a273f, base=#232136
swayimg.text.set_foreground(0xffe0def4)
swayimg.text.set_background(0xcc2a273f) -- surface, semi-transparent
swayimg.text.set_shadow(0x00000000)     -- shadow off, bg already gives contrast

------------------------------------------------------------
-- Keep the text layer hidden until toggled with 't'
------------------------------------------------------------
swayimg.on_initialized(function()
  swayimg.text.hide()
end)

------------------------------------------------------------
-- Rosé Pine Moon palette, for reuse below
------------------------------------------------------------

local rp_base    = 0xff232136
local rp_surface = 0xff2a273f
local rp_overlay = 0xff393552
local rp_text    = 0xffe0def4
local rp_love    = 0xffeb6f92
local rp_gold    = 0xfff6c177
local rp_iris    = 0xffc4a7e7
local rp_hl_med  = 0xff44415a

------------------------------------------------------------
-- Viewer & slideshow: window/image colors
------------------------------------------------------------

swayimg.viewer.set_window_background(rp_base)
swayimg.viewer.set_image_chessboard(16, rp_surface, rp_overlay) -- transparency checker, themed
swayimg.viewer.set_mark_color(rp_gold)

swayimg.slideshow.set_window_background(rp_base)
swayimg.slideshow.set_image_chessboard(16, rp_surface, rp_overlay)
swayimg.slideshow.set_mark_color(rp_gold)

------------------------------------------------------------
-- Adjustable slideshow delay ([ decreases, ] increases)
------------------------------------------------------------
local slideshow_delay = 5 -- starting value, seconds

swayimg.slideshow.set_timeout(slideshow_delay)

swayimg.slideshow.on_key("]", function()
  slideshow_delay = slideshow_delay + 1
  swayimg.slideshow.set_timeout(slideshow_delay)
  swayimg.text.set_status("Slideshow delay: " .. slideshow_delay .. "s")
end)

swayimg.slideshow.on_key("[", function()
  slideshow_delay = math.max(1, slideshow_delay - 1)
  swayimg.slideshow.set_timeout(slideshow_delay)
  swayimg.text.set_status("Slideshow delay: " .. slideshow_delay .. "s")
end)

------------------------------------------------------------
-- Gallery mode: window/thumbnail colors
------------------------------------------------------------

swayimg.gallery.set_window_color(rp_base)
swayimg.gallery.set_unselected_color(rp_surface)
swayimg.gallery.set_selected_color(rp_hl_med)
swayimg.gallery.set_border_color(rp_iris)
swayimg.gallery.set_border_size(3)
swayimg.gallery.set_mark_color(rp_gold)

------------------------------------------------------------
-- Restore picture height on start (viewer + slideshow)
------------------------------------------------------------
swayimg.on_window_resize(function()
  local mode = swayimg.get_mode()
  if mode == "viewer" then
    swayimg.viewer.set_fix_scale("optimal")
  elseif mode == "slideshow" then
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
swayimg.viewer.on_key("g", function() swayimg.viewer.switch_image("first") end)
swayimg.viewer.on_key("Shift-g", function() swayimg.viewer.switch_image("last") end)
swayimg.slideshow.on_key("g", function() swayimg.slideshow.switch_image("first") end)
swayimg.slideshow.on_key("Shift-g", function() swayimg.slideshow.switch_image("last") end)
swayimg.gallery.on_key("g", function() swayimg.gallery.switch_image("first") end)
swayimg.gallery.on_key("Shift-g", function() swayimg.gallery.switch_image("last") end)

-- n / p: next / previous image (nsxiv-style alias for PgDown/PgUp)
swayimg.viewer.on_key("n", function() swayimg.viewer.switch_image("next") end)
swayimg.viewer.on_key("p", function() swayimg.viewer.switch_image("prev") end)

-- hjkl grid navigation in gallery (mirrors nsxiv thumbnail mode)
swayimg.gallery.on_key("h", function() swayimg.gallery.switch_image("left") end)
swayimg.gallery.on_key("l", function() swayimg.gallery.switch_image("right") end)
swayimg.gallery.on_key("k", function() swayimg.gallery.switch_image("up") end)
swayimg.gallery.on_key("j", function() swayimg.gallery.switch_image("down") end)

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
