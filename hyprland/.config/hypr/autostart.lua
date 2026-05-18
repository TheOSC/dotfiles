-- =============================================================================
-- autostart.lua
-- Applications launched once at Hyprland start
-- Uses hl.on("hyprland.start") to prevent re-launch on config reload
-- =============================================================================

hl.on("hyprland.start", function()

    -- Wallpaper daemon
    hl.exec_cmd("awww-daemon")

    -- Restore last wallpaper (awww remembers last set)
    hl.exec_cmd("awww restore")

    -- Status bar
    hl.exec_cmd("waybar")

    -- Notification daemon
    hl.exec_cmd("dunst")

    -- Clipboard history daemon
    hl.exec_cmd("wl-paste --watch cliphist store")

    -- Idle daemon (triggers hyprlock on inactivity)
    hl.exec_cmd("hypridle")

    -- Monitor management daemon
    hl.exec_cmd("hyprdynamicmonitors run")

    -- Nextcloud sync client
    hl.exec_cmd("nextcloud --background")

    -- Policy kit agent (needed for some privilege escalation prompts)
    hl.exec_cmd("uwsm app -- /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

end)


-- Auto-apply monitor layout when a monitor is added
hl.on("monitor.added", function(m)
    local monitors = hl.get_monitors()
    local has_dp4 = false
    local has_dp6 = false
    for _, mon in ipairs(monitors) do
        if mon.name == "DP-4" then has_dp4 = true end
        if mon.name == "DP-6" then has_dp6 = true end
    end
    if has_dp4 and has_dp6 then
        hl.monitor({ output = "DP-4", mode = "1920x1080@60", position = "-1080x0", scale = 1, transform = 3 })
        hl.monitor({ output = "eDP-1", mode = "1920x1080@60", position = "0x0", scale = 1 })
        hl.monitor({ output = "DP-6", mode = "3840x2160@30", position = "0x-2160", scale = 1 })
    end
end)
