# dotenv

Reusable setup for a personal Mac. This repository holds the setup scripts and
package manifest; private keys, credentials, and machine-specific secrets stay
outside it.

## First setup

Download or clone this repository, then run from its directory:

```sh
./setup.sh --dry-run
./setup.sh
```

Run as your normal user. Homebrew's official installer may request your Mac's
administrator password and install Apple command line tools. Enter passwords
only in your local terminal. Open a new terminal after setup.

If Git is not available yet, downloading this repository as a ZIP works too.
Git is part of the package list and can be used to clone the repository afterward.

## Organization

- `setup.sh`: entry point; runs each step in order.
- `scripts/ssh.sh`: creates `~/.ssh` and fixes permissions.
- `scripts/shell.sh`: installs terminal aliases and colors and enables them in zsh.
- `shell/aliases.zsh`: the versioned alias definitions.
- `shell/colors.zsh`: colored file listings and the zsh prompt for Apple Terminal.
- `shell/preferences.zsh`: shared history and completion settings.
- `shell/tools.zsh`: fzf, zoxide, Starship, and direnv shell integrations.
- `starship/starship.toml`: prompt layout using labels supported by standard fonts.
- `git/config` and `git/ignore`: shared Git defaults and macOS ignore patterns.
- `scripts/git.sh`: enables the shared Git defaults without changing your identity.
- `scripts/homebrew.sh`: installs Homebrew if missing and adds its environment to `~/.zprofile`.
- `scripts/apps.sh`: installs the packages in `Brewfile`.
- `scripts/vscode.sh`: merges the versioned VS Code theme into user settings.
- `scripts/vim.sh` and `vim/config.vim`: install native dark Vim colors and a file sidebar.
- `scripts/extensions.sh` and `vscode/extensions.txt`: install the selected editor extensions.
- `scripts/development.sh`: provisions managed runtimes and Docker/Colima configuration.
- `shell/development.zsh`: nvm initialization and architecture-aware development paths.
- `ssh/defaults.conf`: agent and Keychain defaults, with local host rules preserved.
- `colima/default.yaml`: initial container VM resource settings.
- `vscode/settings.json`: VS Code settings managed by this repository.
- `scripts/angry-ip-scanner.sh`: installs a verified official Angry IP Scanner release.
- `Brewfile`: the intended package list, shared across machines.
- `tests/ssh.sh`: isolated checks for SSH permissions and safe reruns.

Run a single step with `./setup.sh --only ssh`, `--only shell`,
`--only angry-ip-scanner`, `--only homebrew`, `--only apps`, `--only development`,
`--only git`, `--only vim`, `--only vscode`, or `--only extensions`.
All steps can be rerun. Existing SSH configuration is preserved, and the Homebrew
shell line is only appended if absent. Package installation uses `--no-upgrade`
so a rerun does not upgrade existing packages. It does not remove extra packages.

## SSH

Directories use mode `700`; config, private keys, authorized keys, and other
regular files use `600`. Public keys and known-host files use `644`. Nested files
owned by your user are included; symlinks are not followed. A symlink at `~/.ssh`
is rejected for manual inspection. The script appends an include for managed
`AddKeysToAgent yes` and `UseKeychain yes` defaults under a `Host *` block.
Existing host settings take precedence; keys and host mappings stay local.
It does not generate keys or change host verification policies.

When ready to create an identity, run this locally, choose a passphrase, and
upload only the public `.pub` file to services you use:

```sh
ssh-keygen -t ed25519 -C "your-email@example.com"
```

Never commit private SSH keys or tokens. `.gitignore` is an extra guard, not a
replacement for inspecting staged changes.

## Terminal aliases

| Alias | Command | Purpose |
| --- | --- | --- |
| `ll` | `ls -lgha` | Detailed listing, including hidden files and readable sizes; omit owner column |
| `la` | `ls -A` | Compact listing, including hidden files except `.` and `..` |
| `..` | `cd ..` | Go up one directory |
| `...` | `cd ../..` | Go up two directories |
| `....` | `cd ../../..` | Go up three directories |
| `code .` | VS Code's bundled command line launcher | Open the current folder in VS Code |
| `gs` | `git status -sb` | Compact Git status with branch |
| `gd` | `git diff` | Unstaged changes |
| `gds` | `git diff --staged` | Staged changes |
| `gl` | `git log --oneline --graph --decorate -20` | Recent commit graph |

Edit `shell/aliases.zsh`, then run `./setup.sh --only shell`. The setup copies
the definitions to `~/.config/dotenv/aliases.zsh` and appends a loading line to
`~/.zshrc` only if absent (or `$ZDOTDIR/.zshrc` when configured). Existing zsh
settings are preserved. Later aliases in your `.zshrc` can override these.
Open a new terminal or run `source ~/.zshrc` to load them into the current one.

On macOS, the `-g` flag in `ll` hides the owner column. Use `ls -lha` instead
if you want to see file owners as well.

## Terminal colors

`shell/colors.zsh` enables native macOS colors for `ls`, `ll`, and `la`:
directories are cyan, symbolic links magenta, and executable files red. The
prompt shows your user and host in green and current directory in cyan. Its
final marker turns red after a command fails. Color resets keep your typed
commands in the terminal's normal text color.

The shell step installs this file and loads it from `.zshrc` alongside aliases.
Edit it and rerun `./setup.sh --only shell` to change the colors or prompt.
Colors are skipped in noninteractive shells and when `TERM=dumb`.
No extra packages or fonts are required.

Open a new terminal or run `source ~/.zshrc` to apply changes. Apple Terminal's
background and font remain controlled by your Terminal profile; this setup
configures command output and the prompt.

## Shell tools and Git

The Brewfile also installs fzf, zoxide, direnv, and Starship. The shell step
enables their integrations when the executables are available. Starship takes
over the prompt, showing the directory, Git branch/changes, relevant language
versions, and duration of slow commands. It uses ASCII labels so Apple Terminal
does not need a special font. The previous colored prompt remains a fallback
when Starship is unavailable.

- **History:** 50,000 entries, shared between terminal windows. Duplicate entries
  are reduced. Commands beginning with a space are omitted from history; this
  is a convenience, not a guarantee that secrets cannot be recorded elsewhere.
- **Completion:** Tab completion with a selectable menu and case-insensitive matching.
- **fzf:** Ctrl+R searches command history, Ctrl+T selects files, Alt+C selects
  directories. Apple Terminal can use Option as Meta in its keyboard profile
  settings to access Alt shortcuts; Ctrl+R works without that change.
- **zoxide:** `z dotenv` jumps to a previously visited directory; `zi` selects one
  interactively. It learns directories as you visit them.
- **direnv:** loads environment variables for individually trusted projects.
  Create an `.envrc` containing `dotenv` to load the project's ignored `.env`,
  inspect it, then run `direnv allow`. The setup never automatically trusts or
  executes project `.envrc` files. Variables unload when you leave the project.

Git defaults select `main` for new repositories, automatic colors, and aliases
`git st`, `git df`, `git ds`, `git lg`, and `git last`. Existing global ignore
configuration is preserved; otherwise the managed ignore file excludes macOS
Finder metadata. The shared config is included from your personal Git config.
Set your identity locally; these details stay outside the repository:

```sh
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

Apply these parts independently with:

```sh
./setup.sh --only apps
./setup.sh --only git
./setup.sh --only shell
```

Open a new terminal afterward. References:
[fzf](https://github.com/junegunn/fzf),
[zoxide](https://github.com/ajeetdsouza/zoxide),
[direnv](https://direnv.net/), and
[Starship configuration](https://starship.rs/config/).

## Packages and updates

The starting package list is Git, GitHub CLI, ripgrep, jq, and wget. Add one
`brew "package-name"` per command line tool or `cask "app-name"` per desktop app
to `Brewfile`, then rerun the apps step.

Desktop apps are Visual Studio Code, Discord, ChatGPT Classic, and Tailscale. Angry IP
Scanner is recorded as a commented entry because its
[Homebrew cask is disabled](https://formulae.brew.sh/cask/angry-ip-scanner).
The setup installs its [official download](https://angryip.org/download/)
with a separate script. Homebrew installs enabled desktop apps
to `/Applications` by default. The `code` alias
uses VS Code's bundled CLI at that location and accepts normal CLI arguments,
including `code .` to open the current folder and `code --wait` to wait for the
editor. Install the apps and shell steps before using it:

```sh
./setup.sh --only apps
./setup.sh --only shell
source ~/.zshrc
code .
```

```sh
brew bundle check --file=Brewfile --no-upgrade
# Explicitly update the declared packages when desired:
brew update
brew bundle install --file=Brewfile
```

The manifest tracks package names, not fixed versions. Future installations use
the versions available from Homebrew at that time. Authentication (`gh auth
login`, SSH service access) is done separately and kept out of this repository.

## Tailscale

The Brewfile installs Tailscale's standalone macOS app with `tailscale-app`.
It uses the native menu-bar interface and is separate from the Homebrew
command-line-only `tailscale` formula. Installation may request administrator
authentication because the app uses a package installer.

```sh
./setup.sh --only apps
# To install just Tailscale:
brew install --cask tailscale-app
```

If installation is interrupted at the administrator-password prompt, Homebrew
may retain a cask record even though the app is missing. Finish in a local
terminal with `brew reinstall --cask tailscale-app` in that case.

After installation, open **Tailscale** from Applications, approve the macOS
network/system extension and VPN configuration when prompted, and sign in to
your Tailscale account. Tailnet membership and authentication remain local;
no auth keys or account information belong in this repo. See the
[official macOS installation guide](https://tailscale.com/docs/install/mac).

## Development tools from the previous-machine audit

The default setup now includes all seven prioritized audit groups. The lower
priority Go, Rust/Solana, Terraform, ImageMagick, Pandoc, and unspecified AI tools
remain project-driven additions; the old machine's entire inventory is not imported.

```sh
./setup.sh --only apps
./setup.sh --only development
./setup.sh --only ssh
./setup.sh --only shell
./setup.sh --only vscode
./setup.sh --only extensions
```

**Python:** Homebrew supplies uv; uv installs Python 3.12. Projects retain their
own `pyproject.toml`, `uv.lock`, and `.python-version`. Run `uv sync` to recreate
environments. No pyenv or existing virtual environments are copied.

**Node/Yarn:** the versioned upstream nvm 0.40.8 installer is checked against a
pinned checksum and leaves shell startup edits to this repo. Node 24 is installed
and becomes the default only when no nvm default exists. The latest available
patch within Node 24 is selected on each run. Node 18/20 are not copied as global
defaults; use `nvm install` and `nvm use` in a project with an `.nvmrc` when it
requires a particular version. Corepack supplies Yarn; the initial global Yarn
is stable, while project `packageManager` and lockfiles determine project usage.
Preserve project `.yarnrc.yml` and `.yarn/` artifacts where applicable.

**Containers:** Docker CLI, Compose, Buildx, and Colima are installed. Docker's
plugin search path is merged into its local config without replacing credentials
or contexts; changed files are backed up locally. The initial Colima profile is
4 CPUs, 4 GiB RAM, and 20 GiB disk. Existing profiles are preserved. Adjust
`~/.colima/default/colima.yaml` for the machine and project workload.

```sh
colima start      # explicitly start the container VM
docker info
docker compose up -d   # from a project with a Compose file
colima stop
```

**Databases:** PostgreSQL 17 and Redis are installed; PostgreSQL tools are added
to the shell path. No services are started by setup. Start them only when needed:

```sh
brew services start postgresql@17
brew services start redis
# Stop later with the corresponding `brew services stop` command.
```

Homebrew may initialize a fresh PostgreSQL data directory as part of installation;
this setup does not migrate any database data. Keep schemas/migrations in projects.

**Deployment:** Google Cloud CLI (`gcloud-cli`), Fly.io, Ansible, AWS CLI, and npm
`firebase-tools` are installed. Firebase is installed under the managed Node 24
version. Authentication, tokens, account selection, and deployment are separate
local actions; setup performs none of those. Project manifests/playbooks belong
with their projects.

**Shortcuts:** `dc` = `docker compose`, `dcl` = `docker compose logs -f`,
`ur` = `uv run`, `gcm` = `git commit -m`, and `ports 3000` inspects connections on
a supplied port with `lsof`. It does not kill any processes.

### Local service shortcuts

| Command | Action |
| --- | --- |
| `dev-start` | Start Colima, PostgreSQL 17, and Redis |
| `dev-stop` | Stop Redis, PostgreSQL 17, and Colima |
| `dev-status` | Show Colima status and Homebrew service status |
| `colima-start` / `colima-stop` | Control Colima individually |
| `pg-start` / `pg-stop` | Control PostgreSQL 17 individually |
| `redis-start` / `redis-stop` | Control Redis individually |

The database start shortcuts use `brew services run`, which starts services
without enabling automatic launch at login. Combined commands attempt every
service even if one fails and return an error if any action fails. Stopping
Colima also stops the VM hosting its containers; stopping databases interrupts
connections to those local services. Setup installs these shortcuts without
starting or stopping anything.

**VS Code:** Prettier, Vue Official, ESLint, Python, Pylance, and Container Tools
extensions are installed. Prettier is selected for JavaScript/TypeScript and
their React variants; Vue Official is selected for Vue. Other editor settings
are retained. Formatter assignments from the old machine were not supplied in
full, so these are explicit new defaults rather than copies of unknown settings.

References: [uv](https://docs.astral.sh/uv/getting-started/installation/),
[Colima](https://colima.run/docs/installation/),
[nvm](https://github.com/nvm-sh/nvm#installing-and-updating), and
[Node release status](https://nodejs.org/en/about/previous-releases).

## Vim colors and file sidebar

Vim uses the built-in **Habamax** dark theme with syntax highlighting. It works
with Apple Terminal's indexed colors, without enabling true color or requiring
plugins, fonts, downloads, or a Homebrew Vim installation. The macOS Vim already
includes it; older Vim releases fall back to **Desert** if the theme is unavailable.

```sh
./setup.sh --only vim --dry-run
./setup.sh --only vim
```

The installer copies `vim/config.vim` to `~/.vim/dotenv.vim` and appends one
source line to `~/.vimrc`. Existing settings are preserved and the previous
`.vimrc` is backed up before its first change. Reruns do not duplicate the source
line. Existing symlinks at either managed file are left unchanged with an error.
Reopen Vim or run `:source ~/.vimrc` to apply the settings.

Try these commands inside Vim to switch themes for the current session:

```vim
:colorscheme habamax
:colorscheme slate
:colorscheme desert
```

For a persistent personal choice, put this **before** the managed source line
in `~/.vimrc`:

```vim
let g:dotenv_vim_colorscheme = 'slate'
```

To change the repository default, edit `vim/config.vim` and rerun the Vim step.

Open a project folder with `vim .` (or `vim path/to/project`) to get a file
tree on the left and an empty editing pane on the right. This uses Vim's
built-in **netrw** browser; no plugins are required. Opening a file directly
with `vim filename` keeps the usual single editor pane.

- Press **Ctrl+W**, then **h** or **l** to move between the left and right panes.
- In the tree, use **j/k** to move and **Enter** to expand a directory or open
  a file in the editing pane.
- Press **backslash**, then **e** (`\\e`) to toggle the sidebar, or use `:Lexplore`.
  If you have a custom Vim leader key, use that key followed by `e` instead.
- Save with `:w` and quit all panes with `:qa` (Vim asks you to save modified files).

## VS Code theme

The setup selects the built-in **Dark Modern** theme and keeps it dark even
when macOS uses a light appearance. No theme extension is needed.

```sh
./setup.sh --only vscode
```

Edit `vscode/settings.json` and rerun this step to customize the selection.
The script requires `jq` from the Brewfile, preserves unrelated settings, and
backs up an existing settings file before changing it. Existing files containing
JSON comments or trailing commas are left unchanged with a message to edit them
manually. This applies to the default VS Code user profile.

To preview another theme in VS Code, press **Cmd+K**, then **Cmd+T** and choose
a theme. [VS Code theme documentation](https://code.visualstudio.com/docs/configure/themes).

## Angry IP Scanner

```sh
./setup.sh --only angry-ip-scanner --dry-run
./setup.sh --only angry-ip-scanner
```

This step works without Homebrew. It downloads the official 3.10.0 release
for Apple Silicon or Intel, verifies the archive against its pinned SHA-256
checksum, checks the bundle version, and installs to `/Applications` when
writable or `~/Applications` otherwise. It leaves an existing installation
unchanged and does not upgrade it automatically. To adopt a new release, update
the version, archive names, and checksums in the script after verifying the
[official release assets](https://github.com/angryip/ipscan/releases/tag/3.10.0).

The app includes its Java runtime. Download quarantine is retained; macOS may
require you to approve the app on first open in System Settings > Privacy &
Security. The setup does not launch the app or run any network scans.

## Verification

```sh
bash tests/ssh.sh
./setup.sh --dry-run
stat -f '%Sp %N' ~/.ssh ~/.ssh/config
brew --version
brew bundle check --file=Brewfile --no-upgrade
```

References: [Homebrew installation](https://docs.brew.sh/Installation) and
[Brewfile documentation](https://docs.brew.sh/Brew-Bundle-and-Brewfile).
