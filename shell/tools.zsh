[[ -o interactive ]] || return 0

if (( $+commands[fzf] )); then
  source <(fzf --zsh)
fi
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi
if [[ "${TERM:-dumb}" != dumb ]] && (( $+commands[starship] )); then
  export STARSHIP_CONFIG="$HOME/.config/dotenv/starship.toml"
  eval "$(starship init zsh)"
fi
# Keep direnv last so project variables are refreshed before the prompt.
if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi
