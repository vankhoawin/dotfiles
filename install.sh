#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing dotfiles from $DOTFILES_DIR"

# Install Oh My Zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "==> Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Install zsh plugins
declare -A plugins=(
  ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
  ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
  ["you-should-use"]="https://github.com/MichaelAquilina/zsh-you-should-use"
)

for plugin in "${!plugins[@]}"; do
  dest="$ZSH_CUSTOM/plugins/$plugin"
  if [ ! -d "$dest" ]; then
    echo "==> Installing $plugin..."
    git clone "${plugins[$plugin]}" "$dest"
  else
    echo "==> $plugin already installed"
  fi
done

# Symlink .zshrc
echo "==> Symlinking .zshrc..."
if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
  mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%s)"
  echo "    (existing .zshrc backed up)"
fi
ln -sf "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

# Make scripts executable
if [ -d "$DOTFILES_DIR/scripts" ]; then
  chmod +x "$DOTFILES_DIR/scripts"/*.sh 2>/dev/null || true
fi

echo "==> Done! Restart your shell or run: source ~/.zshrc"
