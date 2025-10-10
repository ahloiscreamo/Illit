local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- === Appearance ===
config.font = wezterm.font 'Maple Mono NF'
config.font_size = 11.5
config.color_scheme = 'rose-pine-moon'

-- === Padding ===
config.window_padding = {
  left = 15,
  right = 15,
  top = 15,
  bottom = 15,
}

-- === Tab-bar ===
config.enable_tab_bar = false
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_max_width = 24
config.tab_bar_at_bottom = true
config.show_new_tab_button_in_tab_bar = false

-- Match tab bar background with terminal background
config.colors = {
  tab_bar = {
    background = "#232136", -- hide full bar
  },
}

-- Add a gap between tabs visually by padding
config.tab_bar_style = {
  new_tab = wezterm.format({ { Text = "" } }), -- completely hides "+"
}

wezterm.on('format-tab-title', function(tab, tabs, panes, cfg, hover, max_width)
  local rose = {
    base = '#232136',
    active_bg = '#31748f',
    active_fg = '#232136',
    inactive_bg = '#6e6a86',
    inactive_fg = '#232136',
    hover_bg = '#403d52',
    hover_fg = '#c4a7e7',
  }

  local bg = rose.inactive_bg
  local fg = rose.inactive_fg
  local prefix = " "
  local suffix = " "

  if tab.is_active then
    bg = rose.active_bg
    fg = rose.active_fg
    prefix = "  " -- add a little more padding around active tab
    suffix = "  "
  elseif hover then
    bg = rose.hover_bg
    fg = rose.hover_fg
  end

  local title = wezterm.truncate_right(tab.active_pane.title, max_width - 4)

  -- Add small visual gap using transparent separators
  return {
    { Background = { Color = rose.base } },
    { Foreground = { Color = rose.base } },
    { Text = " " }, -- small gap before tab

    { Foreground = { Color = bg } },
    { Text = "" },

    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Text = prefix .. title .. suffix },

    { Background = { Color = rose.base } },
    { Foreground = { Color = bg } },
    { Text = "" },

    { Background = { Color = rose.base } },
    { Foreground = { Color = rose.base } },
    { Text = " " }, -- small gap after tab
  }
end)

-- === Custom keybindings ===
config.keys = wezterm.gui.default_keys()
table.insert(config.keys, {
  key = 'L',
  mods = 'CTRL|SHIFT',
  action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
})
table.insert(config.keys, {
  key = 'D',
  mods = 'CTRL|SHIFT',
  action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
})

return config
