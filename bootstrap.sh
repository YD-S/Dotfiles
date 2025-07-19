#!/bin/bash
set -e

DOTFILES_DIR="$HOME/dotfiles"

echo "🚀 Setting up your Mac..."

# 1️⃣ Install Homebrew if missing
if ! command -v brew &>/dev/null; then
  echo "📦 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 2️⃣ Install all apps from Brewfile
echo "📦 Installing apps via Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# 3️⃣ Install GNU stow for symlinking configs
if ! command -v stow &>/dev/null; then
  brew install stow
fi

echo "🔗 Symlinking dotfiles..."
cd "$DOTFILES_DIR"
stow zsh
stow starship
stow wm

# 4️⃣ Set Zsh as default shell
if [[ "$SHELL" != "/bin/zsh" ]]; then
  echo "🐚 Setting Zsh as default shell..."
  chsh -s /bin/zsh
fi

# 5️⃣ Enable SKHD + Sketchybar
echo "🎹 Enabling SKHD + Sketchybar..."
brew services start skhd
brew services start sketchybar

# 6️⃣ Auto-start WireGuard + JetBrains Toolbox
echo "⚙️ Adding WireGuard + JetBrains Toolbox to startup..."
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/WireGuard.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/JetBrains Toolbox.app", hidden:true}'

# 7️⃣ Setup NVM
echo "⬇️ Installing Node.js via NVM..."
export NVM_DIR="$HOME/.nvm"
mkdir -p $NVM_DIR
source $(brew --prefix nvm)/nvm.sh
nvm install --lts
nvm alias default lts/*

echo "✅ Setup complete! Restart terminal + grant Accessibility permissions for SKHD & Sketchybar."

