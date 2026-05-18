-- keybinds.lua
-- Hyprland 0.55 keybindings
local M = "SUPER"

-- Helper: focus window by class or spawn
local function focus_or_spawn(class, cmd)
    local windows = hl.get_windows({ class = class })
    if windows and #windows > 0 then
        hl.dispatch(hl.dsp.focus({ window = windows[1] }))
    else
        hl.dispatch(hl.dsp.exec_cmd(cmd))
    end
end

-- Applications
hl.bind(M .. " + Return",    hl.dsp.exec_cmd("kitty"))
hl.bind(M .. " + B",         hl.dsp.exec_cmd("firefox-launch"))
hl.bind(M .. " + Space",     hl.dsp.exec_cmd("fuzzel"))
hl.bind(M .. " + E",         hl.dsp.exec_cmd("kitty --class yazi --title 'File Manager' -e yazi"))
hl.bind(M .. " + SHIFT + T", function() focus_or_spawn("btop",        "kitty --class btop --title 'System Monitor' -e btop") end)
hl.bind(M .. " + SHIFT + M", function() focus_or_spawn("pulsemixer",  "kitty --class pulsemixer --title 'Audio Mixer' -e pulsemixer") end)
hl.bind(M .. " + SHIFT + B", function() focus_or_spawn("bluetui",     "kitty --class bluetui --title 'Bluetooth' -e bluetui") end)
hl.bind(M .. " + M",         function() focus_or_spawn("jellyfin-tui","kitty --class jellyfin-tui --title 'Jellyfin Music' -e tmux new-session -A -s music jellyfin-tui") end)
hl.bind(M .. " + n",         function() focus_or_spawn("nmtui",       "kitty --class nmtui --title 'Network' -e nmtui") end)
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
hl.bind(M .. " + L",         hl.dsp.exec_cmd("hyprlock"))
hl.bind(M .. " + SHIFT + R", function() hl.dispatch(hl.dsp.reload()) end)
hl.bind(M .. " + V",         hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"))

-- Emoji picker
hl.bind(M .. " + period", hl.dsp.exec_cmd("rofimoji --selector fuzzel --action copy"))

-- Media keys
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPause",        hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"))
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ --limit 1.0"))
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"))
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"))

-- Screenshots
hl.bind("Print",         hl.dsp.exec_cmd("grimblast --freeze save area /tmp/screenshot.png && wl-copy < /tmp/screenshot.png && satty --filename /tmp/screenshot.png"))
hl.bind(M .. " + Print", hl.dsp.exec_cmd("grimblast save screen ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png"))
