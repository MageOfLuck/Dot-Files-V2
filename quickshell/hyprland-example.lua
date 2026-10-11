-- Add to your existing Lua config; this does not replace it.
-- Use an unused key in place of XF86Launch6 if needed.
hl.bind("XF86Launch6", hl.dsp.exec_cmd('qs -p "$HOME/.config/quickshell/edge-control" ipc call control toggleReserve'))

-- Commands for menu keybinds in your preferred binding format:
-- qs -p "$HOME/.config/quickshell/edge-control" ipc call control toggle audio
-- qs -p "$HOME/.config/quickshell/edge-control" ipc call control toggle bluetooth
-- qs -p "$HOME/.config/quickshell/edge-control" ipc call control toggle network
