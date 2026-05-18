# zshrc.custom

Personal shell config — aliases, functions, prompt, eza, history tuning,
keybindings. Cross-shell: **zsh** on Linux / macOS / WSL, **bash** on Windows
(Git Bash / MINGW64 / MSYS2). Portable bits live in `common/common.sh` and are
sourced by both.

## Install

```sh
./install.sh
exec zsh    # or: exec bash  (on Windows / MINGW64)
```

Verbose and idempotent — safe to re-run any time. The installer auto-detects
your shell and OS:

- **zsh present** → wires `~/.zshrc.custom` + installs Pure prompt
- **MINGW64 / MSYS2** (or zsh missing) → wires `~/.bashrc.custom` + `~/.inputrc.custom`, prompts to install Scoop if absent
- **eza** → via package manager on Linux/macOS, via Scoop on Windows

## Uninstall

```sh
./uninstall.sh
```

Removes the auto-generated stubs (`~/.zshrc.custom`, `~/.bashrc.custom`,
`~/.inputrc.custom`) and strips the injected source lines from `~/.zshrc`,
`~/.bashrc`, and `~/.inputrc`. Leaves Pure, eza, Scoop, and `~/.gitignoreSave`
in place (see the script output to clean them up manually).

## Aliases / functions worth knowing

| name                      | what it does                                                |
| ------------------------- | ----------------------------------------------------------- |
| `gs` `gd` `gl` `gl1` `gl2`| git status / diff / log (with pretty graphs on `gl1` `gl2`) |
| `gpc "msg"`               | `git add -A && commit -m "msg" && git push` (runs `make fclean` first if a Makefile exists) |
| `gign`                    | drop the saved gitignore template into the current dir      |
| `ls l la ll lla lt lta`   | eza with sensible defaults (only set when eza is installed) |

## Keybindings (both shells)

| keys                  | action                |
| --------------------- | --------------------- |
| `Ctrl+←` / `Ctrl+→`   | jump by word          |
| `Ctrl+Backspace`      | delete previous word  |
| `Ctrl+Delete`         | delete next word      |

Zsh handles them via `bindkey` (in `zsh/rc.custom`); bash via readline (in
`bash/inputrc`, included from `~/.inputrc`).

## Layout

```
.
├── common/
│   ├── common.sh           POSIX aliases + functions (sourced by both shells)
│   └── gitignore           template, copied to ~/.gitignoreSave (used by `gign`)
├── zsh/
│   ├── rc.custom           zsh entry point (sourced via stub at ~/.zshrc.custom)
│   └── install.sh          installs Pure prompt
├── bash/
│   ├── rc.custom           bash entry point (sourced via stub at ~/.bashrc.custom)
│   ├── inputrc             readline keybindings (sourced via stub at ~/.inputrc.custom)
│   └── install.sh          installs Scoop (Windows only, asks first)
├── lib/log.sh              logging helpers (colors, step counter)
├── scripts/install_eza.sh  eza binary (GitHub releases on Linux, scoop on Windows)
├── install.sh              dispatcher — detects shell/OS, runs the right flow
├── uninstall.sh            symmetric uninstaller
└── .minttyrc               Git Bash / mintty theme (Windows)
```
