#!/usr/bin/env bash
# =============================================================================
# phase2-bootstrap.sh
# Environment bootstrapper for TheOSC dotfiles
# Run as your normal user (not root) after first boot
# Or run standalone on any existing Arch install
# =============================================================================

set -euo pipefail

# =============================================================================
# COLORS AND FORMATTING
# =============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { echo -e "${BLUE}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*"; exit 1; }
section() { echo -e "\n${BOLD}${CYAN}=== $* ===${RESET}\n"; }
skip()    { echo -e "\033[0;35m[SKIP]${RESET}  $*"; }

confirm() {
    local prompt="$1"
    local response
    while true; do
        read -rp "$(echo -e "${YELLOW}${prompt} [y/n]: ${RESET}")" response
        case "$response" in
            [yY]) return 0 ;;
            [nN]) return 1 ;;
            *) echo "Please answer y or n." ;;
        esac
    done
}

# Installs a package if not already present
# Works with both pacman and yay
install_if_missing() {
    local pkg="$1"
    local manager="${2:-pacman}"
    if pacman -Qi "$pkg" &>/dev/null; then
        skip "${pkg} already installed"
    else
        info "Installing ${pkg}..."
        if [[ "$manager" == "yay" ]]; then
            yay -S --noconfirm "$pkg"
        else
            sudo pacman -S --noconfirm "$pkg"
        fi
        success "${pkg} installed"
    fi
}

# =============================================================================
# SAFETY CHECKS
# =============================================================================

section "Pre-flight Checks"

# Must NOT be root
if [[ $EUID -eq 0 ]]; then
    error "Do not run this script as root. Run as your normal user."
fi
success "Running as user: $(whoami)"

# Must be Arch Linux
if [[ ! -f /etc/arch-release ]]; then
    error "This script is designed for Arch Linux only."
fi
success "Arch Linux detected"

# Check internet
info "Checking internet connectivity..."
if ! ping -c 1 -W 5 archlinux.org &>/dev/null; then
    error "No internet connection. Connect first then re-run.\nHint: use 'nmtui' to connect to WiFi."
fi
success "Internet connection detected"

# Check if coming from phase1 or existing install
if [[ -f ~/.phase1-complete ]]; then
    INSTALL_MODE="phase1"
    info "Phase 1 install detected — full bootstrap mode"
else
    INSTALL_MODE="existing"
    warn "No phase1 marker found — running in existing install mode"
    warn "Already installed packages will be skipped"
fi

# Locate dotfiles repo
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
if [[ ! -f "${DOTFILES_DIR}/.stow-global-ignore" ]]; then
    # Not running from inside dotfiles repo, check common location
    if [[ -d ~/dotfiles ]]; then
        DOTFILES_DIR=~/dotfiles
    else
        error "Cannot locate dotfiles repo. Clone it to ~/dotfiles first:\n  git clone git@github.com:TheOSC/dotfiles.git ~/dotfiles"
    fi
fi
success "Dotfiles repo found at: ${DOTFILES_DIR}"

# =============================================================================
# SYSTEM UPDATE
# =============================================================================

section "System Update"

info "Updating package databases..."
sudo pacman -Sy
success "Package databases updated"

# =============================================================================
# REFLECTOR
# =============================================================================

section "Mirror List"

install_if_missing reflector

info "Updating mirrors..."
sudo reflector --country US --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
success "Mirror list updated"

# =============================================================================
# YAY (AUR HELPER)
# =============================================================================

section "AUR Helper (yay)"

if command -v yay &>/dev/null; then
    skip "yay already installed"
else
    info "Installing yay..."
    sudo pacman -S --noconfirm git base-devel
    cd /tmp
    rm -rf yay
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    rm -rf /tmp/yay
    success "yay installed"
fi

# =============================================================================
# CORE PACKAGES (OFFICIAL REPOS)
# =============================================================================

section "Core Packages"

PACMAN_PACKAGES=(
    # Wayland + Compositor
    hyprland
    hyprpicker
    xdg-desktop-portal-hyprland
    xdg-utils
    qt5-wayland
    qt6-wayland

    # Display manager
    greetd
    greetd-tuigreet

    # Bar
    waybar

    # Notifications
    dunst
    libnotify

    # Launcher
    fuzzel

    # Terminal
    kitty

    # Shell
    zsh
    starship
    zsh-autosuggestions
    zsh-syntax-highlighting
    fzf

    # Editor
    neovim
    luarocks

    # Audio
    pipewire
    pipewire-pulse
    pipewire-alsa
    wireplumber
    pulsemixer

    # Bluetooth
    bluez
    bluez-utils

    # Network
    networkmanager
    openssh

    # Clipboard
    wl-clipboard
    cliphist

    # Screenshot
    grim
    slurp

    # Files
    yazi
    ffmpegthumbnailer
    jq
    poppler
    thunar
    thunar-volman
    gvfs
    gvfs-mtp        # Android/MTP device support
    tumbler             # Thumbnail service for Thunar

    # Fonts
    ttf-jetbrains-mono-nerd
    ttf-nerd-fonts-symbols
    noto-fonts
    noto-fonts-emoji
    papirus-icon-theme

    # GTK theming
    gtk3
    gtk4
    python-gobject

    # Qt theming
    kvantum
    qt5ct
    kvantum-qt5
    qt6ct

    # System tools
    btop
    tmux
    mosh
    lazygit
    git
    stow
    mpv
    firefox
    brightnessctl
    playerctl
    upower
    pavucontrol
    polkit-gnome

    # Hyprland ecosystem
    hypridle
    hyprlock

    # Image handling
    imagemagick
    imv

    # Python (needed for various tools)
    python
    python-pip
    nodejs
    npm

    # Misc utilities
    curl
    wget
    unzip
    zip
    man-db
    man-pages
    gum
)

info "Installing official repo packages..."
for pkg in "${PACMAN_PACKAGES[@]}"; do
    install_if_missing "$pkg"
done
success "Core packages complete"

# =============================================================================
# AUR PACKAGES
# =============================================================================

section "AUR Packages"

AUR_PACKAGES=(
    # Wallpaper
    awww

    # Theme engine
    wallust

    # Bluetooth TUI
    bluetui

    # Screenshot annotation
    satty

    #Hyperdynamicmonitors-bin
    hyprdynamicmonitors-bin

    #unar
    unar

    # Keyring
    gnome-keyring
    libsecret
    seahorse


    # Emoji picker
    rofimoji

    # Firefox theming
    pywalfox

    # Jellyfin
    jellyfin-tui
    jellyfin-mpv-shim

    # Nextcloud sync
    nextcloud-client

    # Remote desktop
    remote-desktop-manager

    # Grimblast (Hyprland screenshot helper)
    grimblast-git

    #Universal Wayland Session Manager
    uwsm
)

info "Installing AUR packages..."
for pkg in "${AUR_PACKAGES[@]}"; do
    install_if_missing "$pkg" yay
done
success "AUR packages complete"
warn "NOTE: Run jellyfin-tui manually on first boot to configure your Jellyfin server and credentials"
warn "NOTE: WireGuard VPN - import conf from UDM SE via: sudo nmcli connection import type wireguard file wg0.conf"

# =============================================================================
# ZSH AS DEFAULT SHELL
# =============================================================================

section "Default Shell"

if [[ "$(getent passwd $(whoami) | cut -d: -f7)" == "$(which zsh)" ]]; then
    skip "zsh already default shell"
else
    info "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
    success "Default shell set to zsh"
    warn "Shell change takes effect on next login"
fi

# =============================================================================
# STOW DOTFILES
# =============================================================================

section "Deploying Dotfiles"

cd "$DOTFILES_DIR"

STOW_PACKAGES=(
    hyprland
    waybar
    zsh
    kitty
    nvim
    dunst
    fuzzel
    yazi
    btop
    mpv
    gtk
    hypridle
    wallust
    scripts
    desktop-entries
    syshelp
    starship
    greetd
    monitors
    systemd
    qt
    kvantum
    vpn
)

info "Creating required directories..."
mkdir -p ~/.config
mkdir -p ~/.local/bin
mkdir -p ~/.local/share/applications
mkdir -p ~/Pictures/wallpapers
mkdir -p ~/Pictures/Screenshots

info "Pre-stow cleanup — removing real files that would conflict with symlinks..."
# Common dirs that get created by apps before stow can symlink them
CLEANUP_PATHS=(
    "$HOME/.config/hypr"
    "$HOME/.config/kitty"
    "$HOME/.config/waybar"
    "$HOME/.config/fuzzel"
    "$HOME/.config/dunst"
    "$HOME/.config/yazi"
    "$HOME/.config/btop"
    "$HOME/.config/zsh"
    "$HOME/.config/syshelp"
    "$HOME/.config/vpn"
    "$HOME/.config/qt5ct"
    "$HOME/.config/qt6ct"
    "$HOME/.config/Kvantum"
    "$HOME/.config/starship"
)
for path in "${CLEANUP_PATHS[@]}"; do
    if [[ -e "$path" && ! -L "$path" ]]; then
        rm -rf "$path"
        info "Removed: $path"
    fi
done

info "Stowing dotfile packages..."
for pkg in "${STOW_PACKAGES[@]}"; do
    if [[ -d "${DOTFILES_DIR}/${pkg}" ]]; then
        stow --restow "$pkg"
        success "Stowed: ${pkg}"
    else
        warn "Package directory not found, skipping: ${pkg}"
    fi
done

# Make scripts executable
chmod +x ~/.local/bin/*
sudo ln -sf "$HOME/.local/bin/firefox-launch"        /usr/local/bin/firefox-launch
sudo ln -sf "$HOME/.local/bin/syshelp"              /usr/local/bin/syshelp
sudo ln -sf "$HOME/.local/bin/thunar-launch"        /usr/local/bin/thunar-launch
sudo ln -sf "$HOME/.local/bin/wallpaper-set"        /usr/local/bin/wallpaper-set
sudo ln -sf "$HOME/.local/bin/wallpaper-random"     /usr/local/bin/wallpaper-random
sudo ln -sf "$HOME/.local/bin/vpn-toggle"           /usr/local/bin/vpn-toggle
sudo ln -sf "$HOME/.local/bin/waybar-vpn-status"    /usr/local/bin/waybar-vpn-status
sudo ln -sf "$HOME/.local/bin/wireplumber-watchdog" /usr/local/bin/wireplumber-watchdog
success "Scripts marked executable"

# =============================================================================
# GREETD CONFIGURATION
# =============================================================================

section "Display Manager"

info "Configuring greetd..."
sudo mkdir -p /etc/greetd
sudo tee /etc/greetd/config.toml > /dev/null << EOF
[terminal]
vt = 1
[default_session]
command = "tuigreet --time --remember --cmd start-hyprland"
user = "greeter"
[initial_session]
command = "start-hyprland"
user = "$(whoami)"
EOF
sudo systemctl enable greetd
success "greetd configured and enabled"

# =============================================================================
# SERVICES
# =============================================================================

section "User Services"

# Pipewire
systemctl --user enable --now pipewire
systemctl --user enable --now pipewire-pulse
systemctl --user enable --now wireplumber
success "Pipewire services enabled"

# Bluetooth
sudo systemctl enable --now bluetooth
sudo systemctl enable --now systemd-resolved
success "Bluetooth enabled"
success "systemd-resolved enabled"

# SSH agent
systemctl --user enable --now ssh-agent
success "SSH agent enabled"

# Audio watchdog
systemctl --user enable --now wireplumber-watchdog
success "Wireplumber watchdog enabled"

# =============================================================================
# GTK DARK MODE
# =============================================================================
section "GTK Dark Mode"
if grep -q "GTK_THEME" /etc/environment 2>/dev/null; then
    skip "GTK dark mode already set in /etc/environment"
else
    info "Setting GTK dark mode in /etc/environment..."
    sudo tee -a /etc/environment << 'ENVEOF'
GTK_THEME=Adwaita:dark
GTK2_RC_FILES=/usr/share/themes/Adwaita-dark/gtk-2.0/gtkrc
ENVEOF
    success "GTK dark mode configured"
fi

# =============================================================================
# PYWALFOX
# =============================================================================

section "Firefox Theming"

info "Installing pywalfox native connector..."
mkdir -p ~/.config/mozilla/firefox
if pywalfox install --profile-path ~/.config/mozilla/firefox 2>/dev/null; then
    success "Pywalfox installed"
else
    warn "Pywalfox install failed — launch Firefox once first, then run: pywalfox install --profile-path ~/.config/mozilla/firefox"
fi
info "After first boot open Firefox and install the Pywalfox extension from addons.mozilla.org"

# =============================================================================
# WALLUST INITIAL RUN
# =============================================================================
section "Neovim Plugin Sync"
info "Syncing Neovim plugins headlessly..."
nvim --headless "+Lazy sync" +qa 2>/dev/null && success "Neovim plugins synced" || warn "Neovim plugin sync failed — run :Lazy sync manually"

section "Initial Theme Generation"
DEFAULT_WALLPAPER=$(find "$HOME/Pictures/wallpapers/" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) 2>/dev/null | head -1)
if [[ -n "$DEFAULT_WALLPAPER" ]]; then
    info "Setting wallpaper and generating theme..."
    wallpaper-set "$DEFAULT_WALLPAPER"
    success "Initial theme generated"
else
    warn "No wallpapers found in ~/Pictures/wallpapers/ — add one and run: wallpaper-set <image>"
fi

# =============================================================================
# PHASE 1 CLEANUP
# =============================================================================

if [[ "$INSTALL_MODE" == "phase1" ]]; then
    rm -f ~/.phase1-complete
    success "Phase 1 marker cleaned up"
fi

# =============================================================================
# COMPLETION
# =============================================================================

section "Bootstrap Complete"

echo -e "${GREEN}${BOLD}╔════════════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}${BOLD}║   Environment bootstrap complete!                  ║${RESET}"
echo -e "${GREEN}${BOLD}║                                                    ║${RESET}"
echo -e "${GREEN}${BOLD}║   Next steps:                                      ║${RESET}"
echo -e "${GREEN}${BOLD}║   1. Reboot into your new desktop                  ║${RESET}"
echo -e "${GREEN}${BOLD}║   2. Open Firefox, install Pywalfox extension      ║${RESET}"
echo -e "${GREEN}${BOLD}║   3. Run jellyfin-tui to configure Jellyfin        ║${RESET}"
echo -e "${GREEN}${BOLD}║   4. Import WireGuard config via nmcli             ║${RESET}"
echo -e "${GREEN}${BOLD}║   5. Hit Super+F1 if you forget anything           ║${RESET}"
echo -e "${GREEN}${BOLD}╚════════════════════════════════════════════════════╝${RESET}"

echo
info "Full keybind reference: Super+F1"
info "Wallpaper library:      ~/Pictures/wallpapers/"
info "Dotfiles location:      ${DOTFILES_DIR}"
info "System reference:       syshelp"
