# System Reference

Last updated: 2026-05

---

## Keybinds

### Applications
| Bind | Action |
|------|--------|
| Super+Enter | Terminal (kitty) |
| Super+B | Browser (firefox) |
| Super+Space | Launcher (fuzzel) |
| Super+E | Files (yazi) |
| Super+M | Jellyfin audio (jellyfin-tui) |
| Super+Shift+T | System monitor (btop) |
| Super+Shift+M | Audio mixer (pulsemixer) |
| Super+Shift+B | Bluetooth (bluetui) |
| Super+F1 | This help screen |

### Window Management
| Bind | Action |
|------|--------|
| Super+Q | Close active window |
| Super+F | Fake fullscreen (bar stays) |
| Super+Shift+F | True fullscreen |
| Super+Tab | Toggle floating |
| Super+/ | Toggle split direction |
| Super+Arrows | Move focus |
| Super+Shift+Arrows | Move window |
| Super+Alt+Mouse | Resize window |
| Super+W/A/S/D | Move window (WASD) |

### Workspaces
| Bind | Action |
|------|--------|
| Super+1-9 | Switch workspace |
| Super+Shift+1-9 | Move window to workspace |
| Super+0 | Remote work workspace (launches RDM if needed) |
| Super+Shift+0 | Move window to workspace 10 |

### System
| Bind | Action |
|------|--------|
| Super+L | Lock screen |
| Super+Shift+R | Reload Hyprland config |
| Super+V | Clipboard history |
| Super+. | Emoji picker |
| Print | Screenshot region + annotate |
| Super+Print | Screenshot fullscreen |
| Super+N | Network TUI (nmtui) |

### Media Keys
| Bind | Action |
|------|--------|
| F1 | Mute / unmute audio |
| F2 | Volume down |
| F3 | Volume up |
| F4 | Mic mute |
| F6 | Brightness down |
| F7 | Brightness up |

---

## Theming

Everything is driven by wallpaper. One command updates all surfaces.

| Command | Action |
|---------|--------|
| wallpaper-set ~/Pictures/wallpapers/image.jpg | Set wallpaper + regenerate theme |
| wallpaper-random | Random wallpaper from ~/Pictures/wallpapers/ |
| hypr-reload | Reload all theme consumers without changing wallpaper |

Theme surfaces updated automatically:
- Hyprland borders
- Waybar
- Kitty terminal
- Dunst notifications
- Fuzzel launcher
- Yazi file manager
- Btop system monitor
- GTK3 + GTK4 apps
- Firefox (via pywalfox)
- Hyprlock screen

---

## Tools Quick Reference

### TUI Apps
| Name | What it does | Launch |
|------|-------------|--------|
| btop | System monitor (CPU, RAM, processes) | Super+Shift+T |
| pulsemixer | Audio volume and routing control | Super+Shift+M |
| bluetui | Bluetooth device management | Super+Shift+B |
| jellyfin-tui | Jellyfin music streaming client | Super+M |
| yazi | File manager with image previews | Super+E |
| lazygit | Git TUI — stage, commit, push | lazygit |
| nmtui | Network/WiFi connection manager | nmtui |
| vpn-toggle | Toggle WireGuard VPN on/off | vpn-toggle |
| vpn-connect | Bring up VPN with route fix | vpn-connect |

### Remote Work (Workspace 0)
| Name | What it does |
|------|-------------|
| RDM Solo | Remote Desktop Manager — RDP, VNC, SSH sessions |
| tmux | Terminal multiplexer — persistent SSH sessions |
| mosh | SSH for unreliable/mobile connections |

### System Tools
| Name | What it does | Notes |
|------|-------------|-------|
| fuzzel | App launcher | Super+Space, searches by keyword |
| dunst | Notification daemon | Runs in background |
| cliphist | Clipboard history | Super+V to browse |
| grimblast | Screenshot capture | Use via Print keybind |
| satty | Screenshot annotation | Opens automatically after region capture |
| hyprdynamicmonitors | Monitor/display profile manager — dock detection, auto switching | hyprdynamicmonitors tui |
| awww | Wallpaper daemon | Managed by wallpaper-set |
| wallust | Theme color engine | Managed by wallpaper-set |
| hypridle | Idle detection → auto lock | Runs in background |
| hyprlock | Lock screen | Super+L or auto on idle |
| thunar | GUI file manager — drag-and-drop, USB/flash mounting | thunar |
---

## Git Basics

| Command | What it does |
|---------|-------------|
| git status | Show what has changed |
| git add . | Stage all changes |
| git add <file> | Stage a specific file |
| git commit -m "message" | Save a snapshot |
| git push | Send commits to GitHub |
| git pull | Get latest from GitHub |
| git log --oneline | See commit history |
| lazygit | Visual TUI for all of the above |

Dotfiles repo: https://github.com/TheOSC/dotfiles

---

## File Locations

| What | Where |
|------|-------|
| Dotfiles repo | ~/dotfiles |
| Wallpapers | ~/Pictures/wallpapers |
| Hyprland config | ~/.config/hypr/ |
| Wallust templates | ~/.config/wallust/templates/ |
| Scripts | ~/.local/bin/ |
| This file | ~/.config/syshelp/reference.md |
| Screenshots | ~/Pictures/Screenshots/ |

---

## If Something Breaks

**Hyprland won't reload config**
Emergency binds are always active: Super+Q (close window), Super+Shift+R (reload config)
Check: hyprctl reload in terminal for error output

**Theme not updating**
Run: wallpaper-set ~/Pictures/wallpapers/yourimage.jpg manually
Check: wallust run ~/Pictures/wallpapers/yourimage.jpg for errors

**No sound**
Check: systemctl --user status pipewire
Fix: systemctl --user restart pipewire wireplumber

**WiFi not connecting**
Run: nmtui → Activate a connection

**Bluetooth not working**
Check: systemctl status bluetooth
Fix: sudo systemctl restart bluetooth
Then open bluetui

---

*Update this file when you add tools or change keybinds.*
*It lives at ~/.config/syshelp/reference.md in your dotfiles repo.*
