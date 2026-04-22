# zshrc.custom

Personal shell config — aliases, functions, Pure prompt, eza, history tuning.
Primary target: zsh on WSL / Linux / macOS. Bash-on-Windows support coming next;
portable bits already live in `common.sh` so they'll be reusable.

## Install

```sh
./install.sh
exec zsh
```

Verbose and idempotent — safe to re-run any time.

## Uninstall

```sh
./uninstall.sh
```

Removes the symlink and strips the source line from `~/.zshrc`. Leaves
`pure`, `eza` and `~/.gitignoreSave` in place (see the script output to clean
them up manually).

## Aliases / functions worth knowing

| name                      | what it does                                                |
| ------------------------- | ----------------------------------------------------------- |
| `gs` `gd` `gl` `gl1` `gl2`| git status / diff / log (with pretty graphs on `gl1` `gl2`) |
| `gpc "msg"`               | `git add -A && commit -m "msg" && git push` (runs `make fclean` first if a Makefile exists) |
| `gign`                    | drop the saved gitignore template into the current dir      |
| `ls l la ll lla lt lta`   | eza with sensible defaults (only set when eza is installed) |

## Layout

```
.
├── .zshrc.custom          zsh entry point (symlinked into ~)
├── common.sh              portable aliases + functions (zsh + bash)
├── install.sh             verbose orchestrator
├── uninstall.sh
├── lib/
│   └── log.sh             logging helpers (colors, step counter)
├── scripts/
│   ├── install_pure.sh    Pure prompt (clone/update)
│   └── install_eza.sh     eza binary (GitHub releases)
├── templates/
│   └── gitignore          copied to ~/.gitignoreSave, used by `gign`
└── .minttyrc              Git Bash / mintty theme (Windows phase)
```
