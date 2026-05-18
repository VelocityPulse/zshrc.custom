#!/usr/bin/env sh
# zshrc.custom installer — verbose, idempotent, safe to re-run.
# Supports zsh on Linux/macOS/WSL and bash on Windows (MINGW/MSYS).
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$REPO_DIR/lib/log.sh"

trap 'log_failed "see the red line above for the cause."' EXIT

# --- environment detection ------------------------------------------------
case "$(uname -s)" in
    MINGW*|MSYS*) IS_MINGW=1 ;;
    *)            IS_MINGW=0 ;;
esac

HAS_ZSH=0;  command -v zsh  >/dev/null 2>&1 && HAS_ZSH=1
HAS_BASH=0; command -v bash >/dev/null 2>&1 && HAS_BASH=1

# Which rc flows do we wire?
# - zsh: whenever zsh is installed.
# - bash: on MINGW/MSYS only (where bash is the primary shell); also as a
#   fallback if zsh is missing.
WIRE_ZSH=$HAS_ZSH
WIRE_BASH=0
if [ "$HAS_BASH" = 1 ] && { [ "$IS_MINGW" = 1 ] || [ "$HAS_ZSH" = 0 ]; }; then
    WIRE_BASH=1
fi

# --- banner ---------------------------------------------------------------
if [ "$HAS_ZSH" = 1 ]; then
    SHELL_LINE="$(zsh --version 2>/dev/null | awk '{print $1, $2}')"
elif [ "$HAS_BASH" = 1 ]; then
    SHELL_LINE="bash $(bash --version 2>/dev/null | head -1 | awk '{print $4}')"
else
    SHELL_LINE="no zsh/bash detected"
fi

TARGET_LINE=""
[ "$WIRE_ZSH"  = 1 ] && TARGET_LINE="$TARGET_LINE ~/.zshrc"
[ "$WIRE_BASH" = 1 ] && TARGET_LINE="$TARGET_LINE ~/.bashrc"
[ -z "$TARGET_LINE" ] && TARGET_LINE=" (none — no shell to wire)"

log_header "zshrc.custom installer" \
    "$SHELL_LINE" \
    "$(uname -srm)" \
    "$(echo $TARGET_LINE)"

log_steps_total 5

# ---------------------------------------------------------------------------
# 1. dependency check
# ---------------------------------------------------------------------------
log_step "Checking dependencies"
missing=""
for dep in git curl; do
    if command -v "$dep" >/dev/null 2>&1; then
        case "$dep" in
            git)  ver="$(git --version 2>/dev/null | awk '{print $NF}')" ;;
            curl) ver="$(curl --version 2>/dev/null | head -1 | awk '{print $2}')" ;;
        esac
        log_ok "$dep  $ver"
    else
        log_error "$dep not found"
        missing="$missing $dep"
    fi
done

# zsh is mandatory only when bash is not the wired shell.
if [ "$WIRE_BASH" = 0 ]; then
    if [ "$HAS_ZSH" = 1 ]; then
        log_ok "zsh  $(zsh --version 2>/dev/null | awk '{print $2}')"
    else
        log_error "zsh not found"
        missing="$missing zsh"
    fi
else
    if [ "$HAS_ZSH" = 1 ]; then
        log_ok "zsh  $(zsh --version 2>/dev/null | awk '{print $2}') (also wiring zsh)"
    else
        log_skip "zsh  not installed (optional on MINGW/MSYS)"
    fi
    log_ok "bash $(bash --version 2>/dev/null | head -1 | awk '{print $4}')"
fi

if [ -n "$missing" ]; then
    if   command -v apt   >/dev/null 2>&1; then log_info "install with:  sudo apt update && sudo apt install$missing"
    elif command -v dnf   >/dev/null 2>&1; then log_info "install with:  sudo dnf install$missing"
    elif command -v brew  >/dev/null 2>&1; then log_info "install with:  brew install$missing"
    elif command -v scoop >/dev/null 2>&1; then log_info "install with:  scoop install$missing"
    else                                        log_info "install the missing packages with your package manager"
    fi
    exit 1
fi

# ---------------------------------------------------------------------------
# 2. write stub rc files into $HOME and wire ~/.zshrc / ~/.bashrc / ~/.inputrc
# ---------------------------------------------------------------------------
# Why stubs and not symlinks? `ln -s` on MINGW silently falls back to copying
# (no Windows symlink without Dev Mode / admin), which breaks idempotence AND
# breaks `$_BC_DIR` resolution in the rc file. A tiny stub that sources the
# repo file by absolute path works identically on every platform.
#
# write_stub <stub_target> <repo_source> <user_rc> <user_rc_directive> <stub_directive>
#   stub_target       e.g. ~/.bashrc.custom
#   repo_source       e.g. /abs/path/to/repo/bash/rc.custom
#   user_rc           e.g. ~/.bashrc
#   user_rc_directive line appended once to user_rc, e.g. "source ~/.bashrc.custom"
#   stub_directive    directive used inside the stub, e.g. "source" or "$include"
STUB_MARKER='# zshrc.custom — auto-generated stub, edit the repo file instead.'

write_stub() {
    _target="$1"; _source="$2"; _user_rc="$3"; _user_rc_directive="$4"; _stub_directive="$5"

    _expected="$STUB_MARKER
$_stub_directive $_source"

    if [ -f "$_target" ] && [ "$(cat "$_target")" = "$_expected" ]; then
        log_skip "stub already up to date: $_target"
    elif [ -e "$_target" ] || [ -L "$_target" ]; then
        # Existing file — could be a previous symlink, an outdated stub, or
        # the user's own file. Back it up unless it's clearly our stub.
        if [ -f "$_target" ] && head -1 "$_target" 2>/dev/null | grep -qF "$STUB_MARKER"; then
            log_info "refreshing outdated stub: $_target"
        else
            log_info "backing up existing $_target → $_target.bak"
            mv "$_target" "$_target.bak"
        fi
        printf '%s\n%s %s\n' "$STUB_MARKER" "$_stub_directive" "$_source" > "$_target"
        log_ok "stub written: $_target"
    else
        printf '%s\n%s %s\n' "$STUB_MARKER" "$_stub_directive" "$_source" > "$_target"
        log_ok "stub written: $_target"
    fi

    if [ -f "$_user_rc" ] && grep -qxF "$_user_rc_directive" "$_user_rc"; then
        log_skip "source line already in $_user_rc"
    else
        printf '\n# zshrc.custom\n%s\n' "$_user_rc_directive" >> "$_user_rc"
        log_ok "added source line to $_user_rc"
    fi
}

log_step "Writing rc stubs"

if [ "$WIRE_ZSH" = 1 ]; then
    write_stub "$HOME/.zshrc.custom" "$REPO_DIR/zsh/rc.custom" \
        "$HOME/.zshrc" "source ~/.zshrc.custom" "source"
fi

if [ "$WIRE_BASH" = 1 ]; then
    write_stub "$HOME/.bashrc.custom" "$REPO_DIR/bash/rc.custom" \
        "$HOME/.bashrc" "source ~/.bashrc.custom" "source"
    write_stub "$HOME/.inputrc.custom" "$REPO_DIR/bash/inputrc" \
        "$HOME/.inputrc" "\$include ~/.inputrc.custom" "\$include"
fi

if [ "$WIRE_ZSH" = 0 ] && [ "$WIRE_BASH" = 0 ]; then
    log_warn "no shell wired — install zsh or run on MINGW/MSYS for bash support"
fi

# ---------------------------------------------------------------------------
# 3. shell-specific install (pure prompt / scoop bootstrap)
# ---------------------------------------------------------------------------
log_step "Shell-specific install"
if [ "$WIRE_ZSH" = 1 ]; then
    sh "$REPO_DIR/zsh/install.sh"
fi
if [ "$WIRE_BASH" = 1 ]; then
    sh "$REPO_DIR/bash/install.sh"
fi
if [ "$WIRE_ZSH" = 0 ] && [ "$WIRE_BASH" = 0 ]; then
    log_skip "nothing to install (no shell wired)"
fi

# ---------------------------------------------------------------------------
# 4. eza
# ---------------------------------------------------------------------------
log_step "Installing eza"
sh "$REPO_DIR/scripts/install_eza.sh"

# ---------------------------------------------------------------------------
# 5. gitignore template
# ---------------------------------------------------------------------------
log_step "Installing gitignore template"
TEMPLATE="$REPO_DIR/common/gitignore"
DEST="$HOME/.gitignoreSave"
if [ -f "$DEST" ] && cmp -s "$TEMPLATE" "$DEST"; then
    log_skip "~/.gitignoreSave already up to date"
else
    cp "$TEMPLATE" "$DEST"
    log_ok "copied to ~/.gitignoreSave  (use \`gign\` to drop it in a repo)"
fi

trap - EXIT

# Final nudge.
if [ "$IS_MINGW" = 1 ]; then
    log_done "Run \`exec bash\` to try it out."
else
    CURRENT_SHELL="$(basename "${SHELL:-}")"
    if [ "$WIRE_ZSH" = 1 ] && [ "$CURRENT_SHELL" != "zsh" ]; then
        printf '\n'
        log_warn "your default shell is $CURRENT_SHELL, not zsh"
        log_info "make zsh your login shell with:  chsh -s \"\$(command -v zsh)\""
    fi
    log_done "Run \`exec zsh\` to try it out."
fi
