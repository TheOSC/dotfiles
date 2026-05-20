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

-- Smart move: tiling neighbors first, then own workspaces, then physical monitor, then create (right only)
local function smart_move(direction)
    local win = hl.get_active_window()
    if win == nil then return end

    local cur_ws_id = win.workspace.id
    local cur_mon_id = win.monitor.id

    local monitors = hl.get_monitors()
    local cur_mon = nil
    for _, m in ipairs(monitors) do
        if m.id == cur_mon_id then
            cur_mon = m
            break
        end
    end
    if cur_mon == nil then return end

    local workspaces = hl.get_workspaces()

    -- Step 1: check for tiling neighbor on current workspace
    local function has_tiling_neighbor(dir)
        local wins = hl.get_workspace_windows(cur_ws_id)
        if wins == nil or #wins <= 1 then return false end
        local wx = win.at.x
        local wy = win.at.y
        local ww = win.size.x
        local wh = win.size.y
        for _, w in ipairs(wins) do
            if w.address ~= win.address then
                if dir == "r" and w.at.x >= wx + ww then return true end
                if dir == "l" and w.at.x + w.size.x <= wx then return true end
                if dir == "u" and w.at.y + w.size.y <= wy then return true end
                if dir == "d" and w.at.y >= wy + wh then return true end
            end
        end
        return false
    end

    if has_tiling_neighbor(direction) then
        hl.dispatch(hl.dsp.window.move({ direction = direction }))
        return
    end

    -- Step 2: left/right only — find next/prev workspace on THIS monitor
    local same_mon_ws = nil
    if direction == "r" then
        for _, ws in ipairs(workspaces) do
            if ws.monitor.id == cur_mon_id and ws.id > cur_ws_id then
                if same_mon_ws == nil or ws.id < same_mon_ws then
                    same_mon_ws = ws.id
                end
            end
        end
    elseif direction == "l" then
        for _, ws in ipairs(workspaces) do
            if ws.monitor.id == cur_mon_id and ws.id < cur_ws_id then
                if same_mon_ws == nil or ws.id > same_mon_ws then
                    same_mon_ws = ws.id
                end
            end
        end
    end

    if same_mon_ws ~= nil then
        hl.dispatch(hl.dsp.window.move({ workspace = tostring(same_mon_ws) }))
        hl.dispatch(hl.dsp.focus({ workspace = tostring(same_mon_ws) }))
        return
    end

    -- Step 3: find physical monitor in that direction
    local function get_monitor_in_direction(dir)
        local best = nil
        local best_dist = math.huge
        for _, m in ipairs(monitors) do
            if m.id ~= cur_mon_id then
                local in_dir = false
                local dist = 0
                if dir == "r" then
                    local cw = math.min(cur_mon.width, cur_mon.height)
                    in_dir = m.x >= cur_mon.x + cw - 1
                    dist = m.x - (cur_mon.x + cw)
                elseif dir == "l" then
                    local mw = math.min(m.width, m.height)
                    in_dir = m.x + mw <= cur_mon.x + 1
                    dist = cur_mon.x - (m.x + mw)
                elseif dir == "u" then
                    in_dir = m.y + m.height <= cur_mon.y + 1
                    dist = cur_mon.y - (m.y + m.height)
                elseif dir == "d" then
                    in_dir = m.y >= cur_mon.y + cur_mon.height - 1
                    dist = m.y - (cur_mon.y + cur_mon.height)
                end
                if in_dir and dist < best_dist then
                    best = m
                    best_dist = dist
                end
            end
        end
        return best
    end

    local target_mon = get_monitor_in_direction(direction)

    if target_mon ~= nil then
        local target_ws_id = target_mon.active_workspace.id
        hl.dispatch(hl.dsp.window.move({ workspace = tostring(target_ws_id) }))
        hl.dispatch(hl.dsp.focus({ workspace = tostring(target_ws_id) }))
        return
    end

    -- Step 4: right only — create new workspace
    if direction == "r" then
        local used = {}
        for _, ws in ipairs(workspaces) do
            used[ws.id] = true
        end
        local next_ws = cur_ws_id + 1
        while used[next_ws] do
            next_ws = next_ws + 1
        end
        hl.dispatch(hl.dsp.window.move({ workspace = tostring(next_ws) }))
        hl.dispatch(hl.dsp.focus({ workspace = tostring(next_ws) }))
        return
    end
end

-- Smart focus: same logic as smart_move but only moves focus, never the window
local function smart_focus(direction)
    local cur_ws = hl.get_active_workspace()
    if cur_ws == nil then return end

    local cur_ws_id = cur_ws.id
    local cur_mon = hl.get_active_monitor()
    if cur_mon == nil then return end

    local cur_mon_id = cur_mon.id
    local monitors = hl.get_monitors()
    local workspaces = hl.get_workspaces()

    -- Step 1: check for tiling neighbor on current workspace
    local active_win = hl.get_active_window()
    if active_win ~= nil then
        local wins = hl.get_workspace_windows(cur_ws_id)
        if wins ~= nil and #wins > 1 then
            local wx = active_win.at.x
            local wy = active_win.at.y
            local ww = active_win.size.x
            local wh = active_win.size.y
            for _, w in ipairs(wins) do
                if w.address ~= active_win.address then
                    if direction == "r" and w.at.x >= wx + ww then
                        hl.dispatch(hl.dsp.focus({ direction = direction }))
                        return
                    end
                    if direction == "l" and w.at.x + w.size.x <= wx then
                        hl.dispatch(hl.dsp.focus({ direction = direction }))
                        return
                    end
                    if direction == "u" and w.at.y + w.size.y <= wy then
                        hl.dispatch(hl.dsp.focus({ direction = direction }))
                        return
                    end
                    if direction == "d" and w.at.y >= wy + wh then
                        hl.dispatch(hl.dsp.focus({ direction = direction }))
                        return
                    end
                end
            end
        end
    end

    -- Step 2: left/right only — find next/prev workspace on THIS monitor
    local same_mon_ws = nil
    if direction == "r" then
        for _, ws in ipairs(workspaces) do
            if ws.monitor.id == cur_mon_id and ws.id > cur_ws_id then
                if same_mon_ws == nil or ws.id < same_mon_ws then
                    same_mon_ws = ws.id
                end
            end
        end
    elseif direction == "l" then
        for _, ws in ipairs(workspaces) do
            if ws.monitor.id == cur_mon_id and ws.id < cur_ws_id then
                if same_mon_ws == nil or ws.id > same_mon_ws then
                    same_mon_ws = ws.id
                end
            end
        end
    end

    if same_mon_ws ~= nil then
        hl.dispatch(hl.dsp.focus({ workspace = tostring(same_mon_ws) }))
        return
    end

    -- Step 3: find physical monitor in that direction
    local function get_monitor_in_direction(dir)
        local best = nil
        local best_dist = math.huge
        for _, m in ipairs(monitors) do
            if m.id ~= cur_mon_id then
                local in_dir = false
                local dist = 0
                if dir == "r" then
                    local cw = math.min(cur_mon.width, cur_mon.height)
                    in_dir = m.x >= cur_mon.x + cw - 1
                    dist = m.x - (cur_mon.x + cw)
                elseif dir == "l" then
                    local mw = math.min(m.width, m.height)
                    in_dir = m.x + mw <= cur_mon.x + 1
                    dist = cur_mon.x - (m.x + mw)
                elseif dir == "u" then
                    in_dir = m.y + m.height <= cur_mon.y + 1
                    dist = cur_mon.y - (m.y + m.height)
                elseif dir == "d" then
                    in_dir = m.y >= cur_mon.y + cur_mon.height - 1
                    dist = m.y - (cur_mon.y + cur_mon.height)
                end
                if in_dir and dist < best_dist then
                    best = m
                    best_dist = dist
                end
            end
        end
        return best
    end

    local target_mon = get_monitor_in_direction(direction)

    if target_mon ~= nil then
        hl.dispatch(hl.dsp.focus({ workspace = tostring(target_mon.active_workspace.id) }))
        return
    end

    -- Step 4: right only — create new workspace and focus it (no window moves)
    if direction == "r" then
        local used = {}
        for _, ws in ipairs(workspaces) do
            used[ws.id] = true
        end
        local next_ws = cur_ws_id + 1
        while used[next_ws] do
            next_ws = next_ws + 1
        end
        hl.dispatch(hl.dsp.focus({ workspace = tostring(next_ws) }))
        return
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

-- Focus — smart: tiling neighbors, then same-monitor workspaces, then physical monitor
hl.bind(M .. " + left",  function() smart_focus("l") end)
hl.bind(M .. " + right", function() smart_focus("r") end)
hl.bind(M .. " + up",    function() smart_focus("u") end)
hl.bind(M .. " + down",  function() smart_focus("d") end)

-- Move windows — arrows
hl.bind(M .. " + SHIFT + left",  function() smart_move("l") end)
hl.bind(M .. " + SHIFT + right", function() smart_move("r") end)
hl.bind(M .. " + SHIFT + up",    function() smart_move("u") end)
hl.bind(M .. " + SHIFT + down",  function() smart_move("d") end)

-- Move windows — WASD
hl.bind(M .. " + A", function() smart_move("l") end)
hl.bind(M .. " + D", function() smart_move("r") end)
hl.bind(M .. " + W", function() smart_move("u") end)
hl.bind(M .. " + S", function() smart_move("d") end)

-- Mouse resize
hl.bind(M .. " + ALT + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Workspaces 1-9
for i = 1, 9 do
    hl.bind(M .. " + " .. tostring(i),         hl.dsp.focus({ workspace = tostring(i) }))
    hl.bind(M .. " + SHIFT + " .. tostring(i), hl.dsp.window.move({ workspace = tostring(i) }))
end

-- System
hl.bind(M .. " + L",         hl.dsp.exec_cmd("hyprlock"))
hl.bind(M .. " + SHIFT + R", function() hl.reload() end)
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
