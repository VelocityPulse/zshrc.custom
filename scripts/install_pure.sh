#!/usr/bin/env sh
# Install or update the Pure zsh prompt into ~/.zsh/pure.
# Idempotent and verbose; safe to re-run.
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../lib/log.sh"

PURE_DIR="$HOME/.zsh/pure"

if [ -d "$PURE_DIR/.git" ]; then
    log_skip "already cloned at $PURE_DIR"
    log_info "pulling latest..."
    if git -C "$PURE_DIR" pull --quiet --ff-only; then
        log_ok "pure up to date"
    else
        log_warn "could not update (offline?) — keeping existing version"
    fi
else
    log_info "cloning sindresorhus/pure into $PURE_DIR"
    mkdir -p "$HOME/.zsh"
    if git clone --quiet --depth=1 https://github.com/sindresorhus/pure.git "$PURE_DIR"; then
        log_ok "pure installed"
    else
        log_error "failed to clone pure"
        exit 1
    fi
fi
