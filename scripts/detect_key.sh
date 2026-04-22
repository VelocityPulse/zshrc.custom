#!/usr/bin/env zsh
# detect_key.sh — press a key combo, see the raw bytes your terminal sends.
# Usage:  zsh scripts/detect_key.sh   (or make it executable and run it directly)
#
# Press Ctrl+C to quit.

set -e

print -P "%F{cyan}Press any key combo. %F{yellow}Ctrl+C%f to quit.%f"
echo

while true; do
    printf '%s' "  key > "

    # Read the first byte (blocks). Then drain any extra bytes that came in the
    # same escape sequence (Alt+X, arrow keys, F-keys, etc.).
    bytes=""
    IFS= read -k 1 -r -s c
    bytes+="$c"
    while IFS= read -k 1 -r -s -t 0.01 c 2>/dev/null; do
        bytes+="$c"
    done

    # Handle Ctrl+C cleanly (byte 0x03).
    if [[ "$bytes" == $'\x03' ]]; then
        echo "bye."
        break
    fi

    printf '    cat -v : %s\n' "$(printf '%s' "$bytes" | cat -v)"
    printf '    hex    : %s\n' "$(printf '%s' "$bytes" | od -An -tx1 | tr -s ' ' | sed 's/^ //')"
    echo
done
