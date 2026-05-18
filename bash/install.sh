#!/usr/bin/env sh
# bash-specific install: bootstraps Scoop on Windows (MINGW/MSYS).
# Idempotent and verbose; safe to re-run. Only meaningful on MINGW/MSYS;
# a no-op elsewhere.
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../lib/log.sh"

case "$(uname -s)" in
    MINGW*|MSYS*) ;;
    *)
        log_skip "not on MINGW/MSYS — nothing bash-specific to install"
        exit 0
        ;;
esac

if command -v scoop >/dev/null 2>&1; then
    log_skip "scoop already installed ($(scoop --version 2>/dev/null | head -1))"
    exit 0
fi

log_info "scoop not found — needed to install eza and other Windows tools"
printf '      → Install Scoop now? [Y/n] '
read -r ans
case "$ans" in
    [nN]*)
        log_warn "skipping scoop install — eza and other tools will be skipped too"
        log_info "you can install scoop later with:"
        log_info "  powershell -c \"iwr -useb get.scoop.sh | iex\""
        exit 0
        ;;
esac

log_info "installing scoop via powershell..."
if powershell -NoProfile -ExecutionPolicy Bypass -Command \
    "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force; iwr -useb get.scoop.sh | iex"; then
    log_ok "scoop installed"
    log_info "you may need to open a new shell for scoop to be on PATH"
else
    log_error "scoop install failed"
    exit 1
fi
