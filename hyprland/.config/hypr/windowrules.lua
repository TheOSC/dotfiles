-- =============================================================================
-- windowrules.lua
-- Window rules for TUI-as-app instances and workspace assignments
-- =============================================================================

-- ---------------------------------------------------------------------------
-- TUI APP FLOATING WINDOWS
-- These are spawned by kitty with --class set to the app name
-- They float at a fixed size, centered, with no terminal chrome visible
-- ---------------------------------------------------------------------------

-- btop — system monitor
hl.window_rule({ rule = "float",              match = { class = "btop" } })
hl.window_rule({ rule = "size 1000 650",      match = { class = "btop" } })
hl.window_rule({ rule = "center",             match = { class = "btop" } })

-- pulsemixer — audio control
hl.window_rule({ rule = "float",              match = { class = "pulsemixer" } })
hl.window_rule({ rule = "size 800 500",       match = { class = "pulsemixer" } })
hl.window_rule({ rule = "center",             match = { class = "pulsemixer" } })

-- bluetui — bluetooth manager
hl.window_rule({ rule = "float",              match = { class = "bluetui" } })
hl.window_rule({ rule = "size 700 450",       match = { class = "bluetui" } })
hl.window_rule({ rule = "center",             match = { class = "bluetui" } })

-- jellycli — jellyfin audio
hl.window_rule({ rule = "float",              match = { class = "jellycli" } })
hl.window_rule({ rule = "size 900 550",       match = { class = "jellycli" } })
hl.window_rule({ rule = "center",             match = { class = "jellycli" } })

-- yazi — file manager (tiled, not floating — more useful with space)
hl.window_rule({ rule = "size 1200 750",      match = { class = "yazi" } })
hl.window_rule({ rule = "center",             match = { class = "yazi" } })

-- lazygit — git TUI
hl.window_rule({ rule = "float",              match = { class = "lazygit" } })
hl.window_rule({ rule = "size 1100 650",      match = { class = "lazygit" } })
hl.window_rule({ rule = "center",             match = { class = "lazygit" } })

-- syshelp — system reference cheatsheet
hl.window_rule({ rule = "float",              match = { class = "syshelp" } })
hl.window_rule({ rule = "size 800 600",       match = { class = "syshelp" } })
hl.window_rule({ rule = "center",             match = { class = "syshelp" } })

-- nmtui — network manager
hl.window_rule({ rule = "float",              match = { class = "nmtui" } })
hl.window_rule({ rule = "size 700 500",       match = { class = "nmtui" } })
hl.window_rule({ rule = "center",             match = { class = "nmtui" } })

-- satty — screenshot annotation
hl.window_rule({ rule = "float",              match = { class = "satty" } })
hl.window_rule({ rule = "center",             match = { class = "satty" } })

-- ---------------------------------------------------------------------------
-- WORKSPACE ASSIGNMENTS
-- ---------------------------------------------------------------------------

-- RDM — always opens on workspace 0 (remote work)
hl.window_rule({ rule = "workspace 0",        match = { class = "rdm" } })
hl.window_rule({ rule = "workspace 0",        match = { class = "RemoteDesktopManager" } })

-- Firefox — workspace 1 by default
hl.window_rule({ rule = "workspace 1",        match = { class = "firefox" } })

-- ---------------------------------------------------------------------------
-- MISC RULES
-- ---------------------------------------------------------------------------

-- Prevent idle inhibit while watching video
hl.window_rule({ rule = "idleinhibit focus",  match = { class = "mpv" } })

-- Float mpv when launched as a small player
hl.window_rule({ rule = "float",              match = { class = "mpv", title = "float" } })

-- Fuzzel stays on top
hl.window_rule({ rule = "stayfocused",        match = { class = "fuzzel" } })
