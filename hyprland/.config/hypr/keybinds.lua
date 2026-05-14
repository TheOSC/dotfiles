-- =============================================================================
-- keybinds.lua
-- All keybindings
-- =============================================================================

local M = "SUPER"

-- =============================================================================
-- APPLICATIONS
-- =============================================================================

-- Terminal
hl.bind(M .. " + Return", hl.dsp.exec_cmd("kitty"))

-- Browser
hl.bind(M .. " + B", hl.dsp.exec_cmd("firefox"))

-- Launcher
hl.bind(M .. " + Space", hl.dsp.exec_cmd("fuzzel"))

-- Files (yazi in kitty with class for window rules)
hl.bind(M .. " + E", hl.dsp.exec_cmd(
    "kitty --class yazi --title 'File Manager' -e yazi"
))

-- System monitor
hl.bind(M .. " + SHIFT + T", hl.dsp.exec_cmd(
    "kitty --class btop --title 'System Monitor' -e btop"
))

-- Audio mixer
hl.bind(M .. " + SHIFT + M", hl.dsp.exec_cmd(
    "kitty --class pulsemixer --title 'Audio Mixer' -e pulsemixer"
))

-- Bluetooth
hl.bind(M .. " + SHIFT + B", hl.dsp.exec_cmd(
    "kitty --class bluetui --title 'Bluetooth' -e bluetui"
))

-- Jellyfin audio
hl.bind(M .. " + M", hl.dsp.exec_cmd(
    "kitty --class jellycli --title 'Jellyfin' -e jellycli"
))

-- Syshelp cheatsheet
hl.bind(M .. " + F1", hl.dsp.exec_cmd(
    "kitty --class syshelp --title 'System Reference' -e syshelp"
))

-- =============================================================================
-- WORKSPACE 0 — REMOTE WORK (smart launch)
-- Checks if RDM is running; launches it if not, then switches to workspace 0
-- =============================================================================
hl.bind(M .. " + 0", function()
    local rdm_running = os.execute("pgrep -x RemoteDesktopMana > /dev/null 2>&1") == 0
    if not rdm_running then
        hl.dispatch(hl.dsp.exec_cmd("rdm"))
    end
    hl.dispatch(hl.dsp.workspace.switch({ workspace = "0" }))
end)

-- =============================================================================
-- WINDOW MANAGEMENT
-- =============================================================================

-- Close active window
hl.bind(M .. " + Q", hl.dsp.window.close())

-- Fake fullscreen (bar stays visible)
hl.bind(M .. " + F", hl.dsp.window.fullscreen({ mode = "maximize" }))

-- True fullscreen
hl.bind(M .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

-- Toggle floating
hl.bind(M .. " + Tab", hl.dsp.window.float({ action = "toggle" }))

-- Toggle split direction
hl.bind(M .. " + slash", hl.dsp.layout("togglesplit"))

-- Move focus with arrow keys
hl.bind(M .. " + left",  hl.dsp.window.focus({ direction = "l" }))
hl.bind(M .. " + right", hl.dsp.window.focus({ direction = "r" }))
hl.bind(M .. " + up",    hl.dsp.window.focus({ direction = "u" }))
hl.bind(M .. " + down",  hl.dsp.window.focus({ direction = "d" }))

-- Move windows with arrow keys
hl.bind(M .. " + SHIFT + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(M .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(M .. " + SHIFT + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(M .. " + SHIFT + down",  hl.dsp.window.move({ direction = "d" }))

-- Resize windows with Super+Alt+Mouse
hl.bind(M .. " + ALT + mouse:272", hl.dsp.window.resize_start())

-- =============================================================================
-- WORKSPACES
-- =============================================================================

-- Switch workspaces 1-9
for i = 1, 9 do
    hl.bind(M .. " + " .. i, hl.dsp.workspace.switch({ workspace = tostring(i) }))
end

-- Move window to workspace 1-9
for i = 1, 9 do
    hl.bind(M .. " + SHIFT + " .. i,
        hl.dsp.window.move_to_workspace({ workspace = tostring(i) }))
end

-- Move window to workspace 0
hl.bind(M .. " + SHIFT + 0",
    hl.dsp.window.move_to_workspace({ workspace = "0" }))

-- =============================================================================
-- SYSTEM
-- =============================================================================

-- Lock screen
hl.bind(M .. " + L", hl.dsp.exec_cmd("hyprlock"))

-- Reload config
hl.bind(M .. " + SHIFT + R", hl.dsp.reload())

-- Wallpaper picker (opens yazi in wallpapers dir)
hl.bind(M .. " + W", hl.dsp.exec_cmd(
    "kitty --class yazi --title 'Wallpaper Picker' -e yazi ~/wallpapers"
))

-- Clipboard history
hl.bind(M .. " + V", hl.dsp.exec_cmd(
    "cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"
))

-- =============================================================================
-- SCREENSHOTS
-- =============================================================================

-- Region select → annotate with satty
hl.bind("Print", hl.dsp.exec_cmd(
    "grimblast save area - | satty --filename -"
))

-- Fullscreen instant (no annotation)
hl.bind(M .. " + Print", hl.dsp.exec_cmd(
    "grimblast save screen ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png"
))
