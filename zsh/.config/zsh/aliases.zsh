# =============================================================================
# aliases.zsh
# Shell aliases
# =============================================================================

# =============================================================================
# NAVIGATION
# =============================================================================
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'           # Return to previous directory

# =============================================================================
# LISTING
# =============================================================================
alias ls='ls --color=auto --group-directories-first'
alias ll='ls -lah --color=auto --group-directories-first'
alias la='ls -A --color=auto --group-directories-first'
alias lt='ls -lahtr --color=auto'     # Sort by time, newest last
alias lS='ls -lahS --color=auto'      # Sort by size

# =============================================================================
# SAFETY NETS
# =============================================================================
alias cp='cp -i'            # Prompt before overwrite
alias mv='mv -i'            # Prompt before overwrite
alias rm='rm -i'            # Prompt before delete
alias mkdir='mkdir -pv'     # Create parents, verbose

# =============================================================================
# EDITOR
# =============================================================================
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias nv='nvim'

# =============================================================================
# SYSTEM
# =============================================================================
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias remove='sudo pacman -Rns'
alias search='pacman -Ss'
alias aur='yay -S'
alias orphans='pacman -Qtdq'
alias clean='sudo pacman -Rns $(pacman -Qtdq) 2>/dev/null || echo "No orphans"'

# System info
alias mem='free -h'
alias disk='df -h'
alias ports='ss -tulpn'
alias cpu='btop'

# =============================================================================
# NETWORKING
# =============================================================================
alias wifi='nmtui'
alias ping='ping -c 5'
alias myip='curl -s ifconfig.me && echo'

# =============================================================================
# GIT
# =============================================================================
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias glog='git log --oneline --graph --decorate'
alias lg='lazygit'

# =============================================================================
# DOTFILES
# =============================================================================
alias dotfiles='cd ~/dotfiles'
alias dots='cd ~/dotfiles'
alias stowit='cd ~/dotfiles && stow --restow *'

# =============================================================================
# THEMING
# =============================================================================
alias wallpaper='wallpaper-set'
alias wallrandom='wallpaper-random'
alias reload='hypr-reload'

# =============================================================================
# MISC
# =============================================================================
alias cat='cat'             # Placeholder — swap for bat if you install it later
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias help='syshelp'        # 'help' opens syshelp reference
alias cls='clear'
alias history='history 1'   # Show full history
alias path='echo $PATH | tr ":" "\n"'  # Print PATH one entry per line
