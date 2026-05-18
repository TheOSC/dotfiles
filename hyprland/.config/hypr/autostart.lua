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

