---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier
local secMod = "ALT"
local thirdMod = "CTRL"

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("wezterm"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("dolphin"))
hl.bind(secMod .. " + V", hl.dsp.exec_cmd("vscodium"))
hl.bind(secMod .. " + B", hl.dsp.exec_cmd("librewolf"))
hl.bind(secMod .. " + D", hl.dsp.exec_cmd("discord"))
hl.bind(secMod .. " + S", hl.dsp.exec_cmd("steam"))
hl.bind(secMod .. " + E", hl.dsp.exec_cmd("easyeffects"))
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("lact"))
hl.bind("XF86Tools", hl.dsp.exec_cmd("onlyoffice-desktopeditors"))
hl.bind("XF86Launch5", hl.dsp.exec_cmd("shelly-ui"))
--unused XF86Launch6, (found using wev)

hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(secMod .. " + C", hl.dsp.window.close())

hl.bind(secMod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))

hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("vicinae toggle"), { description = "Toggle Vicinae launcher" })
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))    -- dwindle only
hl.bind("Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | swappy -f -"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Move active window to a monitor in a direction with thirdMod + secMod + arrow keys
hl.bind(thirdMod .. " + " .. secMod .. " + left",  hl.dsp.window.move({ monitor = "l" }))
hl.bind(thirdMod .. " + " .. secMod .. " + right", hl.dsp.window.move({ monitor = "r" }))
hl.bind(thirdMod .. " + " .. secMod .. " + up",    hl.dsp.window.move({ monitor = "u" }))
hl.bind(thirdMod .. " + " .. secMod .. " + down",  hl.dsp.window.move({ monitor = "d" }))

--script for moving all desktops to new section
for i = 1, 3 do
    hl.bind(secMod .. " + " .. i,         hl.dsp.exec_cmd("~/.config/hypr/scripts/workspace-group.sh " .. i))
    hl.bind(mainMod .. " + " .. i, hl.dsp.exec_cmd("~/.config/hypr/scripts/workspace-group-move.sh " .. i))
end

-- Side-button drag/resize
hl.bind("mouse:275", hl.dsp.window.drag(),   { mouse = true })
hl.bind("mouse:276", hl.dsp.window.resize(), { mouse = true })

--Contains keybinds to launch rivals submap
hl.bind("XF86Launch7", hl.dsp.submap("gaming"))
hl.bind("XF86Launch7", hl.dsp.exec_cmd("notify-send 'Rivals Mode' 'ON'"))

--submap implementation for Rivals (Frees Mouse Buttons)
hl.define_submap("gaming", function()
    hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
    hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
    hl.bind(secMod .. " + C", hl.dsp.window.close())

    hl.bind("XF86Launch7", hl.dsp.submap("reset"))
    hl.bind("XF86Launch7", hl.dsp.exec_cmd("notify-send 'Rivals Mode' 'OFF'"))

    hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
    hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
    hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
    hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))
end)

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
--hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
--hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd(
  "hyprctl dispatch togglefloating active && hyprctl dispatch togglefloating active"
))