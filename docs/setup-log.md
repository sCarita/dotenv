# Setup record

## 2026-10-01 — initial Mac setup

Machine observed: Apple Silicon (`arm64`), macOS 26.5.2.

- Created the reusable setup scripts and core `Brewfile`.
- Ran isolated SSH permission tests successfully, including reruns, config
  preservation, symlink handling, and a dry run on an empty home directory.
- Ran the full setup in dry-run mode successfully.
- Applied the SSH step to this machine. Verified `~/.ssh` is `700` and
  `~/.ssh/config` is `600`.
- Attempted the official Homebrew installation. It requested administrator
  authentication; the run stopped without installing Homebrew.
- Homebrew, its shell environment, and Brewfile packages remain pending.
- Apple command line tools were absent. Git commands were unavailable, so this
  folder has not been initialized as a Git repository yet.

To finish in a local terminal:

```sh
cd /Users/solid/dotenv
./setup.sh
```

Then verify with the commands in `README.md`. Record subsequent setup changes
here, along with the relevant scripts or Brewfile changes.

## 2026-10-01 — terminal aliases

- Added versioned zsh aliases in `shell/aliases.zsh` and a reusable `shell` setup step.
- Installed the definitions to `~/.config/dotenv/aliases.zsh` and enabled them in
  `~/.zshrc`, preserving any existing startup settings.
- Verified Bash/zsh syntax, dry-run behavior, and alias loading in a new
  interactive zsh process. A subsequent dry run did not append another loading line.
- Homebrew and package installation remain pending administrator authentication.

## 2026-10-01 — desktop apps and VS Code launcher

- Added `visual-studio-code`, `discord`, and `chatgpt-classic` to the Brewfile
  after checking their official Homebrew cask entries.
- Recorded Angry IP Scanner as pending in a commented entry: Homebrew's cask
  page marks it disabled. Leaving it enabled would fail package installation.
- Added and installed a `code` alias pointing to VS Code's bundled CLI. Verified
  zsh syntax and that a new interactive shell loads the alias.
- Verified the apps dry run. Actual package installation stopped because
  Homebrew is still absent. The alias cannot launch until VS Code is installed.

## 2026-10-01 — official Angry IP Scanner installation

- Added `scripts/angry-ip-scanner.sh` and `--only angry-ip-scanner` to setup.
- Pinned official release 3.10.0 with SHA-256 digests for both macOS architectures
  from the release's GitHub API asset metadata.
- Installed the Apple Silicon bundle at `/Applications/Angry IP Scanner.app`.
  The archive checksum and bundle version passed verification.
- Confirmed the installed bundle reports version 3.10.0 and has macOS download
  quarantine. The app has not been launched and no network scans were run.
- Checked shell syntax, the full setup dry run, and a rerun of this step, which
  preserved the existing application without downloading or installing again.
- Homebrew and the Brewfile packages still await administrator authentication.

## 2026-10-02 — native terminal colors

- Added `shell/colors.zsh` and installed it through the existing shell step.
- Enabled colored macOS file listings and a zsh prompt with green user/host,
  cyan working directory, and a red marker after a failed command.
- Preserved existing `.zshrc` content and alias loading. No Terminal profile
  preferences were changed.
- Verified Bash/zsh syntax, loading in a new interactive shell, success/error
  prompt colors, colored `ll` output, and omission of colors for `TERM=dumb`.
- A subsequent shell dry run did not append duplicate loading lines.

## 2026-10-02 — VS Code dark theme

- Observed VS Code installed at `/Applications/Visual Studio Code.app` and jq
  available from Homebrew. There was no existing default-profile settings file.
- Added `vscode/settings.json` and the `vscode` setup step, selecting the built-in
  Dark Modern theme and disabling automatic light/dark appearance switching.
- Applied the settings to `~/Library/Application Support/Code/User/settings.json`
  and verified both values. Checked shell syntax and the step's dry run.
- The script merges valid JSON settings and backs up changed existing files.
  JSONC files with comments or trailing commas require manual editing.
- The theme configuration was verified on disk; no visual preview was performed.

## 2026-10-02 — Git defaults and shell tools

- Added fzf, zoxide, direnv, and Starship to the Brewfile and installed them
  with Homebrew: fzf 0.74.4, zoxide 0.10.0, direnv 2.37.1, Starship 1.26.0.
- Installed shared zsh history/completion preferences and the four tool
  integrations. Starship uses a versioned configuration with ASCII labels.
- Enabled shared Git defaults through a global include: `main`, automatic
  colors, inspection aliases, and a global macOS ignore file when none exists.
  Git name and email are still unset and must be supplied locally.
- Verified interactive terminal startup, Ctrl+R's fzf binding, completion,
  zoxide functions, the direnv hook, Starship rendering, and effective Git values.
- Isolated checks confirmed Git identity and existing ignore-file preservation,
  no duplicate includes on rerun, and that an untrusted `.envrc` is not executed.
- Shell/Bash syntax checks passed. Configuration and tool usage are documented
  in the README. No projects were automatically trusted by direnv.

## 2026-10-02 — previous-machine audit migration

- User supplied a read-only usage audit of the previous machine and explicitly
  selected all prioritized groups, including databases and deployment tools.
- Added and installed uv, Docker CLI/Compose/Buildx, Colima, PostgreSQL 17,
  Redis, Google Cloud CLI, Fly.io, Ansible, and AWS CLI through the Brewfile.
  Homebrew reports all 23 declared dependencies satisfied.
- Provisioned uv-managed Python 3.12.15, upstream nvm 0.40.8, Node 24.21.0,
  Yarn 4.18.1 via Corepack, and Firebase CLI 15.32.1. Node 24 is the new default;
  project runtime/package-manager version requirements remain project-local.
- Merged Docker plugin discovery while preserving other JSON fields and plugin
  order. Added a Colima profile of 4 CPUs, 4 GiB RAM, and 20 GiB disk.
- Added `dc`, `dcl`, `ur`, `gcm`, and the validated `ports PORT` helper, plus
  nvm and architecture-aware Python/PostgreSQL/Google Cloud shell paths.
- Added macOS SSH agent/Keychain defaults after local host rules, preserving
  their precedence. SSH permission and rerun tests passed; effective agent
  behavior is enabled and managed files have mode 600.
- Installed Prettier, Vue Official, ESLint, Python, Pylance, and Container Tools
  extensions; verified all six via a rerun that performed no installs.
- Verified runtime and CLI versions, formatter settings, Docker Compose/Buildx
  discovery, shell aliases, port argument validation, and JSON field/order
  preservation. Shell syntax and the full setup dry run passed.
- Colima, PostgreSQL, and Redis services remain stopped. Container execution,
  database connectivity, cloud login, and deployments were not performed.
- Lower-priority tools from the audit were not imported wholesale. No history,
  private SSH material, credentials, old VM state, or database data was copied.

## 2026-10-02 — complete setup rerun

- Ran `./setup.sh` end to end successfully (exit code 0).
- All 23 Brewfile dependencies are installed. Python 3.12 and Node 24.21.0
  were reused; Yarn, Docker plugin discovery, Git defaults, VS Code settings,
  and all six requested extensions completed successfully.
- Verified Brewfile satisfaction, SSH modes (directory 700; managed files 600),
  and the configured global Git identity.
- Colima, PostgreSQL, and Redis remain stopped, as intended by setup.

## 2026-10-02 — local service shortcuts

- Added and installed `dev-start`, `dev-stop`, and `dev-status`, plus individual
  start/stop aliases for Colima, PostgreSQL 17, and Redis.
- Database starts use `brew services run` so they do not enable launch at login.
  Combined start/stop functions attempt all services and return a failure if any
  action fails.
- Verified zsh syntax and that the installed alias file defines all shortcuts.
  No services were started or stopped while installing or verifying shortcuts.

## 2026-10-03 — version control

- Initialized this directory as a Git repository on `main`.
- Organized the reusable setup into separate commits for shared helpers, SSH,
  Homebrew/packages, Git defaults, development tools, shell configuration,
  VS Code, Angry IP Scanner, and documentation.
- Checked Bash/zsh syntax, VS Code JSON validity, SSH permission/rerun tests,
  and staged whitespace before committing.
- Machine credentials, private keys, runtime state, and personal configuration
  remain outside the repository. No remote repository or push was requested.

## 2026-10-20 — Vim color schemes

- Added `vim/config.vim` and the `--only vim` setup step. The default Habamax
  dark theme enables syntax highlighting; Slate and Desert are documented
  alternatives. Themes are bundled with macOS Vim, so no package downloads or
  plugins were necessary. True color is not forced on Apple Terminal.
- Installed the configuration to `~/.vim/dotenv.vim` and enabled it in `~/.vimrc`.
- Verified the installed theme, dark background, and syntax highlighting in
  headless Vim. Isolated checks passed for dry runs, preserving existing settings,
  backing up `.vimrc`, reruns without duplicate source lines, a personal theme
  override, and fallback to Desert when a requested theme is unavailable.
- Bash syntax and Git whitespace checks passed. The installer and documentation
  are committed with the Vim configuration.
