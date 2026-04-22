# lib/log.sh — logging helpers for the installer.
# Source me, don't execute.
#
# Public API:
#   log_steps_total N      declare the total number of steps
#   log_step "Title"       start a new step (auto-increments counter)
#   log_info  "text"       arrow   (→)   in-progress / informational
#   log_ok    "text"       check   (✓)   success
#   log_skip  "text"       dot     (·)   already done / no-op
#   log_warn  "text"       bang    (!)   non-fatal warning
#   log_error "text"       cross   (✗)   failure (stderr)
#   log_header TITLE SHELL OS TARGET
#   log_done   "trailer"
#   log_failed "reason"

if [ -t 1 ] && [ "${NO_COLOR:-}" = "" ]; then
    C_RESET=$(printf '\033[0m')
    C_DIM=$(printf '\033[2m')
    C_BOLD=$(printf '\033[1m')
    C_RED=$(printf '\033[31m')
    C_GREEN=$(printf '\033[32m')
    C_YELLOW=$(printf '\033[33m')
    C_BLUE=$(printf '\033[34m')
    C_MAGENTA=$(printf '\033[35m')
    C_CYAN=$(printf '\033[36m')
else
    C_RESET=''; C_DIM=''; C_BOLD=''
    C_RED=''; C_GREEN=''; C_YELLOW=''
    C_BLUE=''; C_MAGENTA=''; C_CYAN=''
fi

LOG_STEP_CURRENT=0
LOG_STEP_TOTAL=0

log_steps_total() { LOG_STEP_TOTAL="$1"; }

log_step() {
    LOG_STEP_CURRENT=$((LOG_STEP_CURRENT + 1))
    printf '\n%s[%d/%d]%s %s%s%s\n' \
        "$C_BOLD$C_BLUE" "$LOG_STEP_CURRENT" "$LOG_STEP_TOTAL" "$C_RESET" \
        "$C_BOLD" "$1" "$C_RESET"
}

log_info()  { printf '      %s→%s %s\n' "$C_CYAN"   "$C_RESET" "$1"; }
log_ok()    { printf '      %s✓%s %s\n' "$C_GREEN"  "$C_RESET" "$1"; }
log_skip()  { printf '      %s·%s %s%s%s\n' "$C_DIM" "$C_RESET" "$C_DIM" "$1" "$C_RESET"; }
log_warn()  { printf '      %s!%s %s\n' "$C_YELLOW" "$C_RESET" "$1"; }
log_error() { printf '      %s✗%s %s\n' "$C_RED"    "$C_RESET" "$1" >&2; }

log_header() {
    _title="$1"; _shell="$2"; _os="$3"; _target="$4"
    printf '\n'
    printf '%s╭─ %s%s\n' "$C_CYAN" "$_title" "$C_RESET"
    printf '%s│%s shell  : %s\n' "$C_CYAN" "$C_RESET" "$_shell"
    printf '%s│%s os     : %s\n' "$C_CYAN" "$C_RESET" "$_os"
    printf '%s│%s target : %s\n' "$C_CYAN" "$C_RESET" "$_target"
    printf '%s╰──%s\n' "$C_CYAN" "$C_RESET"
}

log_done() {
    printf '\n%s✓ All done.%s %s\n\n' "$C_BOLD$C_GREEN" "$C_RESET" "${1:-}"
}

log_failed() {
    printf '\n%s✗ Installation failed.%s %s\n\n' "$C_BOLD$C_RED" "$C_RESET" "${1:-}" >&2
}
