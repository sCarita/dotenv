[[ -o interactive ]] || return 0

# Make Homebrew available in non-login interactive shells, too.
if ! (( $+commands[brew] )); then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_FIND_NO_DUPS HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS HIST_IGNORE_SPACE

# Cache completion data separately from versioned configuration.
mkdir -p "$HOME/.cache/dotenv"
autoload -Uz compinit
compinit -d "$HOME/.cache/dotenv/zcompdump"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select
