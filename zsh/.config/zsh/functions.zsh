# =============================================================================
# functions.zsh
# Shell functions
# =============================================================================

# =============================================================================
# FILESYSTEM
# =============================================================================

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract any archive format
extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2)  tar xjf "$1"     ;;
            *.tar.gz)   tar xzf "$1"     ;;
            *.tar.xz)   tar xJf "$1"     ;;
            *.tar.zst)  tar --zstd -xf "$1" ;;
            *.tar)      tar xf "$1"      ;;
            *.bz2)      bunzip2 "$1"     ;;
            *.gz)       gunzip "$1"      ;;
            *.zip)      unzip "$1"       ;;
            *.7z)       7z x "$1"        ;;
            *.rar)      unar "$1"        ;;
            *.zst)      zstd -d "$1"     ;;
            *)          echo "Unknown archive format: $1" ;;
        esac
    else
        echo "File not found: $1"
    fi
}

# Quick backup of a file
bak() {
    cp "$1" "${1}.bak.$(date +%Y%m%d_%H%M%S)"
    echo "Backup created: ${1}.bak.$(date +%Y%m%d_%H%M%S)"
}

# =============================================================================
# SYSTEM
# =============================================================================

# Show top 10 largest files/dirs in current directory
biggest() {
    du -sh -- * | sort -rh | head -10
}

# Quick process search
psg() {
    ps aux | grep -v grep | grep -i "$1"
}

# Show which package owns a file
owns() {
    pacman -Qo "$1"
}

# =============================================================================
# NETWORKING
# =============================================================================

# Simple HTTP server in current directory
serve() {
    local port="${1:-8000}"
    echo "Serving on http://localhost:${port}"
    python3 -m http.server "$port"
}

# =============================================================================
# GIT
# =============================================================================

# Quick dotfiles update — add all, commit with message, push
dot-push() {
    local msg="${1:-update dotfiles $(date +%Y-%m-%d)}"
    cd ~/dotfiles || return 1
    git add .
    git commit -m "$msg"
    git push
    echo "Dotfiles pushed: $msg"
}

# Show git log as a pretty tree
glt() {
    git log \
        --graph \
        --abbrev-commit \
        --decorate \
        --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' \
        --all
}

# =============================================================================
# THEMING
# =============================================================================

# Pick wallpaper interactively using yazi
wallpick() {
    local selected
    selected=$(find ~/Pictures/wallpapers -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" \
        -o -iname "*.png" -o -iname "*.webp" \) \
        | fzf --preview 'kitty icat --clear --transfer-mode=memory \
            --unicode-placeholder --stdin=no \
            --place=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0 {}' \
            --preview-window=right:60%)
    if [[ -n "$selected" ]]; then
        wallpaper-set "$selected"
    fi
}

# =============================================================================
# DEVELOPMENT
# =============================================================================

# Show $PATH entries one per line, deduplicated
pathlist() {
    echo "$PATH" | tr ':' '\n' | sort -u
}

# Find files by name (case insensitive)
ff() {
    find . -iname "*${1}*" 2>/dev/null
}

# Find files containing text
fg() {
    grep -ril "$1" . 2>/dev/null
}
