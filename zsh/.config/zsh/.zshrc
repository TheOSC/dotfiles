# =============================================================================
# .zshrc
# Main zsh configuration
# Sources modular files from ~/.config/zsh/
# =============================================================================

# =============================================================================
# XDG BASE DIRS — set early so everything respects them
# =============================================================================
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# =============================================================================
# ZSH CORE OPTIONS
# =============================================================================

# History
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS       # Don't record duplicate commands
setopt HIST_IGNORE_SPACE      # Don't record commands starting with space
setopt HIST_VERIFY            # Show history expansion before running
setopt SHARE_HISTORY          # Share history across all sessions
setopt APPEND_HISTORY         # Append rather than overwrite history file

# Directory
setopt AUTO_CD                # Type directory name to cd into it
setopt AUTO_PUSHD             # Push dirs onto stack automatically
setopt PUSHD_IGNORE_DUPS      # No duplicate dirs on stack
setopt PUSHD_SILENT           # Don't print stack on pushd/popd

# Completion
setopt ALWAYS_TO_END          # Move cursor to end after completion
setopt AUTO_MENU              # Show completion menu on tab
setopt COMPLETE_IN_WORD       # Complete from both ends of word
#setopt CORRECT                # Suggest corrections for mistyped commands

# Misc
setopt INTERACTIVE_COMMENTS   # Allow comments in interactive shell
setopt NO_BEEP                # Never beep

# =============================================================================
# HISTORY STATE DIR
# =============================================================================
mkdir -p "$XDG_STATE_HOME/zsh"

# =============================================================================
# COMPLETION SYSTEM
# =============================================================================
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"
mkdir -p "$XDG_CACHE_HOME/zsh"

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # Case insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion::complete:*' gain-privileges 1

# =============================================================================
# KEYBINDINGS
# =============================================================================
bindkey -e                              # Emacs-style line editing
bindkey '^[[A' history-search-backward # Up arrow — history search
bindkey '^[[B' history-search-forward  # Down arrow — history search
bindkey '^[[H' beginning-of-line       # Home
bindkey '^[[F' end-of-line             # End
bindkey '^[[3~' delete-char            # Delete
bindkey '^H' backward-kill-word        # Ctrl+Backspace — delete word back
bindkey '^[[1;5C' forward-word         # Ctrl+Right — forward word
bindkey '^[[1;5D' backward-word        # Ctrl+Left — backward word

# =============================================================================
# ENVIRONMENT
# =============================================================================
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LESS="-R --mouse"
export MANPAGER="nvim +Man!"           # Open man pages in nvim

# Path — add user bins
export PATH="/usr/local/bin:/usr/bin:/bin:$HOME/.local/bin:$PATH"

# Terminal colors from wallust
# Sources the generated sequences on shell start
if [[ -f "$XDG_CACHE_HOME/wallust/sequences" ]]; then
    cat "$XDG_CACHE_HOME/wallust/sequences"
fi

# SSH agent
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# Qt theming
export QT_QPA_PLATFORMTHEME="qt6ct"

# =============================================================================
# PLUGINS
# Arch packages: zsh-autosuggestions, zsh-syntax-highlighting
# =============================================================================

# Autosuggestions — gray ghost text as you type
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#555555"
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
fi

# Syntax highlighting — must be sourced last
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# =============================================================================
# SOURCE MODULAR CONFIG FILES
# =============================================================================
ZSHCONFIG="$XDG_CONFIG_HOME/zsh"

[[ -f "$ZSHCONFIG/aliases.zsh" ]]   && source "$ZSHCONFIG/aliases.zsh"
[[ -f "$ZSHCONFIG/functions.zsh" ]] && source "$ZSHCONFIG/functions.zsh"
[[ -f "$ZSHCONFIG/prompt.zsh" ]]    && source "$ZSHCONFIG/prompt.zsh"

# Show system info on first terminal of session
if [ -z "$FASTFETCH_SHOWN" ]; then
    export FASTFETCH_SHOWN=1
    fastfetch
fi
