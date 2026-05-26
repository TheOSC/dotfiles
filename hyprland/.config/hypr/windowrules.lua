-- windowrules.lua
-- Hyprland 0.55 syntax

-- btop
hl.window_rule({ match = { class = "btop" },       float = true })
hl.window_rule({ match = { class = "btop" },       size = { 1000, 650 } })
hl.window_rule({ match = { class = "btop" },       center = true })
-- pulsemixer
hl.window_rule({ match = { class = "pulsemixer" }, float = true })
hl.window_rule({ match = { class = "pulsemixer" }, size = { 800, 500 } })
hl.window_rule({ match = { class = "pulsemixer" }, center = true })
-- bluetui
hl.window_rule({ match = { class = "bluetui" },    float = true })
hl.window_rule({ match = { class = "bluetui" },    size = { 700, 450 } })
hl.window_rule({ match = { class = "bluetui" },    center = true })
-- subtui
hl.window_rule({ match = { title = "Music" },   float = true })
hl.window_rule({ match = { title = "Music" },   size = { 900, 600 } })
hl.window_rule({ match = { title = "Music" },   center = true })
-- yazi
hl.window_rule({ match = { class = "yazi" },       size = { 1200, 750 } })
hl.window_rule({ match = { class = "yazi" },       center = true })
-- lazygit
hl.window_rule({ match = { class = "lazygit" },    float = true })
hl.window_rule({ match = { class = "lazygit" },    size = { 1100, 650 } })
hl.window_rule({ match = { class = "lazygit" },    center = true })
-- syshelp
hl.window_rule({ match = { class = "syshelp" },    float = true })
hl.window_rule({ match = { class = "syshelp" },    size = { 800, 600 } })
hl.window_rule({ match = { class = "syshelp" },    center = true })
-- nmtui
hl.window_rule({ match = { class = "nmtui" },      float = true })
hl.window_rule({ match = { class = "nmtui" },      size = { 700, 500 } })
hl.window_rule({ match = { class = "nmtui" },      center = true })
-- satty
hl.window_rule({ match = { class = "satty" },      float = true })
hl.window_rule({ match = { class = "satty" },      center = true })
-- hyprdynamicmonitors
hl.window_rule({ match = { class = "hyprdynamicmonitors" }, float = true })
hl.window_rule({ match = { class = "hyprdynamicmonitors" }, size = { 900, 600 } })
hl.window_rule({ match = { class = "hyprdynamicmonitors" }, center = true })
-- Workspace assignments
-- Misc
-- RDM — main window tiles on workspace 10, dialogs float and center
hl.window_rule({ match = { class = "RemoteDesktopManager", title = "Remote Desktop Manager" }, workspace = "10", float = false })
hl.window_rule({ match = { class = "RemoteDesktopManager" }, center = true })
hl.window_rule({ match = { class = "RemoteDesktopManager", title = "(?!Remote Desktop Manager).*" }, float = true })
-- Thunar dialogs — center only
hl.window_rule({ match = { class = "thunar" }, center = true })
