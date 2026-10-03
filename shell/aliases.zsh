# Directory listings (macOS ls flags).
alias ll='ls -lgha'
alias la='ls -A'

# Navigation.
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# VS Code CLI: `code .` opens the current project; other CLI arguments work too.
alias code='"/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"'

# Git inspection.
alias gs='git status -sb'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate -20'
alias gcm='git commit -m'

# Common development operations from the previous machine's usage audit.
alias dc='docker compose'
alias dcl='docker compose logs -f'
alias ur='uv run'

# Local services. `run` starts databases without enabling launch at login.
alias colima-start='colima start'
alias colima-stop='colima stop'
alias pg-start='brew services run postgresql@17'
alias pg-stop='brew services stop postgresql@17'
alias redis-start='brew services run redis'
alias redis-stop='brew services stop redis'

# Attempt all three even if one fails; report failure to the caller/prompt.
dev-start() {
  local result=0
  command colima start || result=1
  command brew services run postgresql@17 || result=1
  command brew services run redis || result=1
  return "$result"
}

dev-stop() {
  local result=0
  command brew services stop redis || result=1
  command brew services stop postgresql@17 || result=1
  command colima stop || result=1
  return "$result"
}

dev-status() {
  command colima status
  command brew services list
}

ports() {
  if (( $# != 1 )) || [[ "$1" != <1-65535> ]]; then
    print -u2 'Usage: ports PORT (1-65535)'
    return 2
  fi
  command lsof -nP -i ":$1"
}
