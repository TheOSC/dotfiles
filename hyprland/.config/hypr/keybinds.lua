-- keybinds.lua
-- Hyprland 0.55 keybindings
local M = "SUPER"
-- Applications
hl.bind(M .. " + Return",    hl.dsp.exec_cmd("kitty"))
hl.bind(M .. " + B",         hl.dsp.exec_cmd("firefox-launch"))
hl.bind(M .. " + Space",     hl.dsp.exec_cmd("fuzzel"))
hl.bind(M .. " + E",         hl.dsp.exec_cmd("kitty --class yazi --title 'File Manager' -e yazi"))
hl.bind(M .. " + SHIFT + T", hl.dsp.exec_cmd("kitty --class btop --title 'System Monitor' -e btop"))
hl.bind(M .. " + SHIFT + M", hl.dsp.exec_cmd("kitty --class pulsemixer --title 'Audio Mixer' -e pulsemixer"))
hl.bind(M .. " + SHIFT + B", hl.dsp.exec_cmd("kitty --class bluetui --title 'Bluetooth' -e bluetui"))
hl.bind(M .. " + M",         hl.dsp.exec_cmd("kitty --class jellyfin-tui --title 'Jellyfin Music' -e tmux new-session -A -s music jellyfin-tui"))
hl.bind(M .. " + F1",        hl.dsp.exec_cmd("kitty --class syshelp --title 'System Reference' -e syshelp"))
-- Remote work
hl.bind(M .. " + 0", function()
    hl.dispatch(hl.dsp.focus({ workspace = "10" }))
    hl.dispatch(hl.dsp.exec_cmd("/usr/bin/remotedesktopmanager"))
end)
hl.bind(M .. " + SHIFT + 0", hl.dsp.window.move({ workspace = "10" }))
-- Window management
hl.bind(M .. " + Q",         hl.dsp.window.close())
hl.bind(M .. " + F",         hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(M .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(M .. " + Tab",       hl.dsp.window.float({ action = "toggle" }))
hl.bind(M .. " + slash",     hl.dsp.layout("togglesplit"))
-- Focus
hl.bind(M .. " + left",  hl.dsp.focus({ direction = "l" }))
hl.bind(M .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(M .. " + up",    hl.dsp.focus({ direction = "u" }))
hl.bind(M .. " + down",  hl.dsp.focus({ direction = "d" }))
-- Move windows — arrows
hl.bind(M .. " + SHIFT + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(M .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(M .. " + SHIFT + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(M .. " + SHIFT + down",  hl.dsp.window.move({ direction = "d" }))
-- Move windows — WASD
hl.bind(M .. " + A", hl.dsp.window.move({ direction = "l" }))
hl.bind(M .. " + D", hl.dsp.window.move({ direction = "r" }))
hl.bind(M .. " + W", hl.dsp.window.move({ direction = "u" }))
hl.bind(M .. " + S", hl.dsp.window.move({ direction = "d" }))
-- Mouse resize
hl.bind(M .. " + ALT + mouse:273", hl.dsp.window.resize(), { mouse = true })
-- Workspaces 1-9
for i = 1, 9 do
    hl.bind(M .. " + " .. tostring(i),         hl.dsp.focus({ workspace = tostring(i) }))
    hl.bind(M .. " + SHIFT + " .. tostring(i), hl.dsp.window.move({ workspace = tostring(i) }))
end
-- System
hl.bind(M .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(M .. " + SHIFT + R", function() hl.dispatch(hl.dsp.reload()) end)
hl.bind(M .. " + V",         hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"))
-- Network
hl.bind(M .. " + n",          hl.dsp.exec_cmd("kitty --class nmtui --title 'Network' -e nmtui"))

-- Emoji picker
hl.bind(M .. " + period", hl.dsp.exec_cmd("rofimoji --selector fuzzel --action copy"))

-- Monitor profile
hl.bind(M .. " + SHIFT + D", hl.dsp.exec_cmd("monitor-setup"))

-- Media keys
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ --limit 1.0"))
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"))
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"))

-- Screenshots
hl.bind("Print",          hl.dsp.exec_cmd("grimblast --freeze save area - | satty --filename -"))
hl.bind(M .. " + Print",  hl.dsp.exec_cmd("grimblast save screen ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png"))
