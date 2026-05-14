# dotfiles

Arch Linux + Hyprland configuration and install scripts for TheOSC.

---

## Fresh Install (From Arch ISO)

Boot the Arch ISO, connect to the internet, then run:

```bash
curl -fsSL https://raw.githubusercontent.com/TheOSC/dotfiles/main/install/phase1-install.sh | bash
```

Or inspect before running (recommended):

```bash
curl -fsSL https://raw.githubusercontent.com/TheOSC/dotfiles/main/install/phase1-install.sh -o phase1-install.sh
less phase1-install.sh
bash phase1-install.sh
```

Phase 1 will ask a few questions then handle everything through reboot.

---

## Existing Arch Install (Phase 2 Only)

If you already have a base Arch install and just want the environment:

```bash
git clone git@github.com:TheOSC/dotfiles.git ~/dotfiles
bash ~/dotfiles/install/phase2-bootstrap.sh
```

---

## What Gets Installed

| Category | Tool |
|---|---|
| Compositor | Hyprland |
| Bar | Waybar |
| Terminal | Kitty |
| Shell | Zsh + Starship |
| Editor | Nvim |
| Launcher | Fuzzel |
| Files | Yazi |
| Browser | Firefox |
| Audio | Pipewire + Pulsemixer |
| Jellyfin | Jellycli + MPV |
| Bluetooth | Bluetui |
| Network | NetworkManager + Nmtui |
| Clipboard | Cliphist |
| Screenshots | Grimblast + Satty |
| Wallpaper | Awww |
| Theming | Wallust |
| Remote Work | RDM + Tmux + Mosh |
| System Monitor | Btop |
| Git TUI | Lazygit |
| Display Manager | Greetd + Tuigreet |

---

## Keybinds

| Bind | Action |
|---|---|
| Super+Enter | Terminal (kitty) |
| Super+B | Browser (firefox) |
| Super+Space | Launcher (fuzzel) |
| Super+Q | Close active window |
| Super+F | Fake fullscreen |
| Super+Shift+F | True fullscreen |
| Super+M | Jellyfin audio (jellycli) |
| Super+E | Files (yazi) |
| Super+Shift+T | System monitor (btop) |
| Super+Shift+M | Audio mixer (pulsemixer) |
| Super+Shift+B | Bluetooth (bluetui) |
| Print | Screenshot region → annotate |
| Super+Print | Screenshot fullscreen |
| Super+V | Clipboard history |
| Super+L | Lock screen |
| Super+F1 | Syshelp cheatsheet |
| Super+Tab | Toggle floating |
| Super+/ | Toggle split direction |
| Super+Arrows | Move focus |
| Super+Shift+Arrows | Move window |
| Super+Alt+Mouse | Resize window |
| Super+1-9 | Switch workspace |
| Super+Shift+1-9 | Move window to workspace |
| Super+0 | Remote work (RDM, workspace 0) |
| Super+Shift+R | Reload Hyprland config |
| Super+W | Select wallpaper |

---

## Structure
