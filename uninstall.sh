#!/usr/bin/env sh
# zshrc.custom uninstaller — reverses install.sh.
# Leaves pure, eza, and ~/.gitignoreSave in place (easy to remove manually).
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$REPO_DIR/lib/log.sh"

log_header "zshrc.custom uninstaller" \
    "$(zsh --version 2>/dev/null | head -1 || echo 'zsh not found')" \
    "$(uname -srm)" \
    "$HOME/.zshrc"

log_steps_total 3

# ---------------------------------------------------------------------------
# 1. remove symlink
# ---------------------------------------------------------------------------
log_step "Removing ~/.zshrc.custom"
if [ -L "$HOME/.zshrc.custom" ]; then
    rm "$HOME/.zshrc.custom"
    log_ok "symlink removed"
    if [ -e "$HOME/.zshrc.custom.bak" ]; then
        mv "$HOME/.zshrc.custom.bak" "$HOME/.zshrc.custom"
        log_info "restored previous ~/.zshrc.custom.bak"
    fi
else
    log_skip "no symlink to remove"
fi

# ---------------------------------------------------------------------------
# 2. strip source line from ~/.zshrc
# ---------------------------------------------------------------------------
log_step "Cleaning ~/.zshrc"
if [ -f "$HOME/.zshrc" ] && grep -q "source ~/.zshrc.custom" "$HOME/.zshrc"; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.bak"
    # Remove the source line and an optional preceding "# zshrc.custom" marker.
    grep -v -e '^# zshrc.custom$' -e '^source ~/.zshrc.custom$' "$HOME/.zshrc.bak" > "$HOME/.zshrc"
    log_ok "source line removed (backup at ~/.zshrc.bak)"
else
    log_skip "no source line in ~/.zshrc"
fi

# ---------------------------------------------------------------------------
# 3. leftovers
# ---------------------------------------------------------------------------
log_step "Leftovers (not removed automatically)"
log_info "pure prompt    :  ~/.zsh/pure"
log_info "eza binary     :  ~/.local/bin/eza"
log_info "gitignore save :  ~/.gitignoreSave"
log_info "to clean: rm -rf ~/.zsh/pure ~/.local/bin/eza ~/.gitignoreSave"

log_done "Your shell is back to the previous state. Open a new terminal."
