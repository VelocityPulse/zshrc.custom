#!/usr/bin/env sh
# Install the eza binary from GitHub releases into ~/.local/bin.
# Idempotent and verbose; safe to re-run.
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../lib/log.sh"

EZA_DIR="$HOME/.local/bin"

if command -v eza >/dev/null 2>&1; then
    log_skip "already installed: $(eza --version | head -1)"
    exit 0
fi

# --- Windows (MINGW/MSYS): delegate to scoop -----------------------------
case "$(uname -s)" in
    MINGW*|MSYS*)
        if command -v scoop >/dev/null 2>&1; then
            log_info "installing eza via scoop"
            if scoop install eza; then
                log_ok "eza installed via scoop"
            else
                log_error "scoop install eza failed"
                exit 1
            fi
        else
            log_warn "scoop not available — skipping eza"
            log_info "install scoop then re-run, or:  scoop install eza"
        fi
        exit 0
        ;;
esac

mkdir -p "$EZA_DIR"

ARCH="$(uname -m)"
case "$ARCH" in
    x86_64)        ARCH="x86_64" ;;
    aarch64|arm64) ARCH="aarch64" ;;
    *) log_error "unsupported architecture: $ARCH"; exit 1 ;;
esac

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
case "$OS" in
    linux)  OS_TAG="unknown-linux-gnu" ;;
    *) log_error "unsupported OS for prebuilt eza: $OS"; exit 1 ;;
esac

log_info "detected ${ARCH}-${OS}"

log_info "fetching latest release tag..."
LATEST="$(curl -fsSL https://api.github.com/repos/eza-community/eza/releases/latest \
    | grep '"tag_name"' | head -1 | cut -d'"' -f4)"
if [ -z "$LATEST" ]; then
    log_error "could not fetch latest eza release (rate-limited? offline?)"
    exit 1
fi
log_info "latest version: $LATEST"

URL="https://github.com/eza-community/eza/releases/download/${LATEST}/eza_${ARCH}-${OS_TAG}.tar.gz"
log_info "downloading $URL"

if curl -fsSL "$URL" | tar xz -C "$EZA_DIR"; then
    log_ok "eza installed to $EZA_DIR"
else
    log_error "download or extraction failed"
    exit 1
fi

case ":$PATH:" in
    *":$EZA_DIR:"*) : ;;
    *) log_warn "$EZA_DIR is not in your PATH — add it to your shell rc:"
       log_info "  export PATH=\"\$HOME/.local/bin:\$PATH\"" ;;
esac
