#!/bin/zsh

if [ -d "$HOME/.zsh/pure" ]; then
    echo "Pure already installed, updating..."
    git -C "$HOME/.zsh/pure" pull
else
    echo "Installing Pure..."
    mkdir -p "$HOME/.zsh"
    git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
fi

if grep -q "prompt pure" ~/.zshrc; then
    echo "Pure already configured in .zshrc"
else
    echo "Configuring Pure in .zshrc..."
    cat >> ~/.zshrc << 'EOF'

# Pure prompt
fpath+=($HOME/.zsh/pure)
autoload -U promptinit; promptinit
prompt pure
EOF
fi

# --- Reload ---
source ~/.zshrc
