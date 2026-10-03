# Native zsh/macOS colors; no plugins or special fonts required.
[[ -o interactive && "${TERM:-dumb}" != dumb ]] || return 0

# macOS ls colors: cyan directories, magenta symlinks, red executables.
export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad
alias ls='ls -G'

# User/host in green, directory in cyan, prompt marker red after a failed command.
# zsh's %F/%f escapes keep cursor positioning correct for long input lines.
PROMPT='%F{green}%n@%m%f %F{cyan}%~%f %(?.%F{green}.%F{red})%#%f '
