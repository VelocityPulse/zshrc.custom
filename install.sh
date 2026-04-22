#!/usr/bin/env sh
# zshrc.custom installer — verbose, idempotent, safe to re-run.
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$REPO_DIR/lib/log.sh"

trap 'log_failed "see the red line above for the cause."' EXIT

# --- banner ---
if command -v zsh >/dev/null 2>&1; then
    ZSH_VERSION_LINE="$(zsh --version 2>/dev/null | awk '{print $1, $2}')"
else
    ZSH_VERSION_LINE="not installed yet"
fi
log_header "zshrc.custom installer" \
    "$ZSH_VERSION_LINE" \
    "$(uname -srm)" \
    "$HOME/.zshrc"

log_steps_total 5

# ---------------------------------------------------------------------------
# 1. dependency check
# ---------------------------------------------------------------------------
log_step "Checking dependencies"
missing=""
for dep in git curl zsh; do
    if command -v "$dep" >/dev/null 2>&1; then
        case "$dep" in
            git)  ver="$(git --version 2>/dev/null | awk '{print $NF}')" ;;
            curl) ver="$(curl --version 2>/dev/null | head -1 | awk '{print $2}')" ;;
            zsh)  ver="$(zsh --version 2>/dev/null | awk '{print $2}')" ;;
        esac
        log_ok "$dep  $ver"
    else
        log_error "$dep not found"
        missing="$missing $dep"
    fi
done
if [ -n "$missing" ]; then
    if command -v apt >/dev/null 2>&1; then
        log_info "install with:  sudo apt update && sudo apt install$missing"
    elif command -v dnf >/dev/null 2>&1; then
        log_info "install with:  sudo dnf install$missing"
    elif command -v brew >/dev/null 2>&1; then
        log_info "install with:  brew install$missing"
    else
        log_info "install the missing packages with your package manager"
    fi
    exit 1
fi

# ---------------------------------------------------------------------------
# 2. link .zshrc.custom into $HOME and wire ~/.zshrc
# ---------------------------------------------------------------------------
log_step "Linking .zshrc.custom"
TARGET="$HOME/.zshrc.custom"
SOURCE="$REPO_DIR/.zshrc.custom"

if [ -L "$TARGET" ] && [ "$(readlink "$TARGET")" = "$SOURCE" ]; then
    log_skip "symlink already points to $SOURCE"
elif [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
    log_info "backing up existing $TARGET → $TARGET.bak"
    mv "$TARGET" "$TARGET.bak"
    ln -s "$SOURCE" "$TARGET"
    log_ok "symlink created"
else
    ln -s "$SOURCE" "$TARGET"
    log_ok "symlink created"
fi

if [ -f "$HOME/.zshrc" ] && grep -q "source ~/.zshrc.custom" "$HOME/.zshrc"; then
    log_skip "source line already in ~/.zshrc"
else
    printf '\n# zshrc.custom\nsource ~/.zshrc.custom\n' >> "$HOME/.zshrc"
    log_ok "added source line to ~/.zshrc"
fi

# ---------------------------------------------------------------------------
# 3. pure prompt
# ---------------------------------------------------------------------------
log_step "Installing Pure prompt"
sh "$REPO_DIR/scripts/install_pure.sh"

# ---------------------------------------------------------------------------
# 4. eza
# ---------------------------------------------------------------------------
log_step "Installing eza"
sh "$REPO_DIR/scripts/install_eza.sh"

# ---------------------------------------------------------------------------
# 5. gitignore template
# ---------------------------------------------------------------------------
log_step "Installing gitignore template"
TEMPLATE="$REPO_DIR/templates/gitignore"
DEST="$HOME/.gitignoreSave"
if [ -f "$DEST" ] && cmp -s "$TEMPLATE" "$DEST"; then
    log_skip "~/.gitignoreSave already up to date"
else
    cp "$TEMPLATE" "$DEST"
    log_ok "copied to ~/.gitignoreSave  (use \`gign\` to drop it in a repo)"
fi

trap - EXIT

# Final nudge if zsh isn't the default login shell yet.
CURRENT_SHELL="$(basename "${SHELL:-}")"
if [ "$CURRENT_SHELL" != "zsh" ]; then
    printf '\n'
    log_warn "your default shell is $CURRENT_SHELL, not zsh"
    log_info "make zsh your login shell with:  chsh -s \"\$(command -v zsh)\""
fi

log_done "Run \`exec zsh\` to try it out."
