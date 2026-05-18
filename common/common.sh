# common.sh — portable aliases and functions, sourced by both zsh and bash.
# Keep this POSIX-ish: no zsh-only syntax here.

# --- git aliases ---
alias gd="git diff"
alias gs="git status"
alias gl="git log"
alias gl1="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all"
alias gl2="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'"

# --- git helpers ---

# Drop the saved gitignore template into the current directory.
gign() {
    cp "$HOME/.gitignoreSave" .gitignore
}

# Add everything, commit with a message, push. Usage: gpc "my message"
gpc() {
    if [ -z "$1" ]; then
        echo "usage: gpc \"commit message\"" >&2
        return 1
    fi
    if [ -e Makefile ]; then
        make fclean
    fi
    git status && git add -A && git status && git commit -m "$1" && git push
}

# --- eza (modern ls replacement) ---
# Guard so the aliases never shadow ls if eza is missing.
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --group-directories-first'
    alias l='eza --group-directories-first'
    alias la='eza -a --group-directories-first'
    alias ll='eza -l --group-directories-first --git'
    alias lla='eza -la --group-directories-first --git'
    alias lt='eza --tree --level=2 --group-directories-first'
    alias lta='eza --tree --level=2 -a --group-directories-first'
fi
