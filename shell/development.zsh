[[ -o interactive ]] || return 0

typeset -U path
path=("$HOME/.local/bin" $path)
if (( $+commands[brew] )); then
  _dotenv_brew_prefix="$(brew --prefix)"
  if [[ -d "$_dotenv_brew_prefix/opt/postgresql@17/bin" ]]; then
    path=("$_dotenv_brew_prefix/opt/postgresql@17/bin" $path)
  fi
  if [[ -d "$_dotenv_brew_prefix/share/google-cloud-sdk/bin" ]]; then
    path+=("$_dotenv_brew_prefix/share/google-cloud-sdk/bin")
  fi
  unset _dotenv_brew_prefix
fi
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
[[ ! -s "$NVM_DIR/nvm.sh" ]] || source "$NVM_DIR/nvm.sh"
