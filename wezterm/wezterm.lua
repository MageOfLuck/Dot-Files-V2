local wezterm = require 'wezterm'
local config = wezterm.config_builder and wezterm.config_builder() or {}
config.enable_wayland = true
-- Font
config.font = wezterm.font_with_fallback {
  'JetBrains Mono',
  'JetBrainsMono Nerd Font',
}
config.font_size = 12.0
-- Colors
config.color_scheme = 'Catppuccin Mocha'
-- Window
config.window_background_opacity = 0.9
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}
config.keys = {
  {
    key = '|',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = '_',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  -- Pane navigation
  {
    key = 'LeftArrow',
    mods = 'ALT',
    action = wezterm.action.ActivatePaneDirection 'Left',
  },
  {
    key = 'RightArrow',
    mods = 'ALT',
    action = wezterm.action.ActivatePaneDirection 'Right',
  },
  {
    key = 'UpArrow',
    mods = 'ALT',
    action = wezterm.action.ActivatePaneDirection 'Up',
  },
  {
    key = 'DownArrow',
    mods = 'ALT',
    action = wezterm.action.ActivatePaneDirection 'Down',
  },
  -- Pane resizing
  {
    key = 'LeftArrow',
    mods = 'CTRL|SHIFT|ALT',
    action = wezterm.action.AdjustPaneSize { 'Left', 3 },
  },
  {
    key = 'RightArrow',
    mods = 'CTRL|SHIFT|ALT',
    action = wezterm.action.AdjustPaneSize { 'Right', 3 },
  },
  {
    key = 'UpArrow',
    mods = 'CTRL|SHIFT|ALT',
    action = wezterm.action.AdjustPaneSize { 'Up', 3 },
  },
  {
    key = 'DownArrow',
    mods = 'CTRL|SHIFT|ALT',
    action = wezterm.action.AdjustPaneSize { 'Down', 3 },
  },
}
config.selection_word_boundary = ' \t\n{}[]()"\'`,;:'
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = wezterm.action.CompleteSelection 'PrimarySelection',
  },
}
-- Tabs
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
return config
