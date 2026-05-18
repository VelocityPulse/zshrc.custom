#!/usr/bin/env sh
# zshrc.custom uninstaller — reverses install.sh, symmetric across zsh + bash.
# Leaves pure, eza, scoop, and ~/.gitignoreSave in place (easy to remove manually).
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$REPO_DIR/lib/log.sh"

# Header — best-effort shell version line.
if command -v zsh >/dev/null 2>&1; then
    SHELL_LINE="$(zsh --version 2>/dev/null | head -1)"
elif command -v bash >/dev/null 2>&1; then
    SHELL_LINE="bash $(bash --version 2>/dev/null | head -1 | awk '{print $4}')"
else
    SHELL_LINE="no zsh/bash detected"
fi

log_header "zshrc.custom uninstaller" \
    "$SHELL_LINE" \
    "$(uname -srm)" \
    "~/.zshrc ~/.bashrc ~/.inputrc"

log_steps_total 3

# ---------------------------------------------------------------------------
# 1. remove our stub files (or legacy symlinks)
# ---------------------------------------------------------------------------
STUB_MARKER='# zshrc.custom — auto-generated stub, edit the repo file instead.'

# unlink_rc <target> — remove if it's our stub OR a symlink (legacy); restore .bak if present.
unlink_rc() {
    _target="$1"
    _removed=0
    if [ -L "$_target" ]; then
        rm "$_target"
        log_ok "removed symlink $_target"
        _removed=1
    elif [ -f "$_target" ] && head -1 "$_target" 2>/dev/null | grep -qF "$STUB_MARKER"; then
        rm "$_target"
        log_ok "removed stub $_target"
        _removed=1
    else
        log_skip "no zshrc.custom stub at $_target"
    fi
    if [ "$_removed" = 1 ] && [ -e "$_target.bak" ]; then
        mv "$_target.bak" "$_target"
        log_info "restored previous $_target.bak"
    fi
}

log_step "Removing rc stubs"
unlink_rc "$HOME/.zshrc.custom"
unlink_rc "$HOME/.bashrc.custom"
unlink_rc "$HOME/.inputrc.custom"

# ---------------------------------------------------------------------------
# 2. strip injected source lines from ~/.zshrc / ~/.bashrc / ~/.inputrc
# ---------------------------------------------------------------------------
# strip_source <user_rc> <source_line_regex>
strip_source() {
    _user_rc="$1"; _line_re="$2"
    if [ -f "$_user_rc" ] && grep -qE "$_line_re" "$_user_rc"; then
        cp "$_user_rc" "$_user_rc.bak"
        # Drop our marker comment + the source line itself.
        grep -vE -e '^# zshrc\.custom$' -e "$_line_re" "$_user_rc.bak" > "$_user_rc"
        log_ok "cleaned $_user_rc (backup at $_user_rc.bak)"
    else
        log_skip "nothing to clean in $_user_rc"
    fi
}

log_step "Cleaning user rc files"
strip_source "$HOME/.zshrc"   '^source ~/\.zshrc\.custom$'
strip_source "$HOME/.bashrc"  '^source ~/\.bashrc\.custom$'
strip_source "$HOME/.inputrc" '^\$include ~/\.inputrc\.custom$'

# ---------------------------------------------------------------------------
# 3. leftovers
# ---------------------------------------------------------------------------
log_step "Leftovers (not removed automatically)"
log_info "pure prompt    :  ~/.zsh/pure"
log_info "eza binary     :  ~/.local/bin/eza  (or via scoop on Windows)"
log_info "scoop          :  ~/scoop           (Windows only)"
log_info "gitignore save :  ~/.gitignoreSave"
log_info "to clean (Linux): rm -rf ~/.zsh/pure ~/.local/bin/eza ~/.gitignoreSave"

log_done "Your shell is back to the previous state. Open a new terminal."
