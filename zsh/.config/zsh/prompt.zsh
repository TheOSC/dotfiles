# =============================================================================
# prompt.zsh
# Starship prompt initialization
# =============================================================================

# Starship reads ~/.config/starship.toml
# We keep a minimal config that fits our aesthetic
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

eval "$(starship init zsh)"
