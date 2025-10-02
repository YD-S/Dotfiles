#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${1:-$HOME/dotfiles}"

echo "🚀 Setting up Linux from $DOTFILES_DIR"

sudo add-apt-repository ppa:danielrichter2007/grub-customizer

# --- 1) Update system + deps ---
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential curl wget ca-certificates \
  libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
  libffi-dev libncurses5-dev libncursesw5-dev xz-utils tk-dev \
  liblzma-dev libxml2 libxmlsec1 pkg-config git firefox grub-customizer

# --- 2) Homebrew on Linux ---
if ! command -v brew >/dev/null 2>&1; then
  echo "📦 Installing Linuxbrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# --- 3) Brewfile_linux ---
if [ -f "$DOTFILES_DIR/Brewfile_linux" ]; then
  brew bundle --file="$DOTFILES_DIR/Brewfile_linux"
fi

# --- 4) Stow configs ---
cd "$DOTFILES_DIR"
stow starship
stow alacritty
stow keybinds
# For zsh, symlink Linux-specific file
ln -sf "$DOTFILES_DIR/zsh/.zshrc_linux" "$HOME/.zshrc"

# --- 5) Zsh default shell ---
if [[ "$SHELL" != "$(which zsh)" ]]; then
  chsh -s "$(which zsh)"
fi

# --- 6) NVM ---
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm install --lts
nvm alias default lts/*

# --- 7) Pyenv ---
if ! command -v pyenv >/dev/null 2>&1; then
  brew install pyenv || curl https://pyenv.run | bash
fi
echo "Setting Python 3.13.5 as global default..."
pyenv global 3.13.5

# --- 8) JetBrains Toolbox autostart ---
JB_BIN="$(command -v jetbrains-toolbox 2>/dev/null || echo "/home/linuxbrew/.linuxbrew/bin/jetbrains-toolbox")"
if [ -x "$JB_BIN" ]; then
  mkdir -p "$HOME/.config/autostart"
  cat > "$HOME/.config/autostart/jetbrains-toolbox.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=JetBrains Toolbox
Exec=$JB_BIN
X-GNOME-Autostart-enabled=true
Terminal=false
EOF
fi

# --- 9) WireGuard ---
sudo apt install -y wireguard wireguard-tools
for conf in /etc/wireguard/*.conf; do
  [ -e "$conf" ] || continue
  name="$(basename "$conf" .conf)"
  sudo systemctl enable --now "wg-quick@$name"
done

# --- 10) sxhkd autostart ---
if ! grep -q "sxhkd" "$HOME/.zprofile" 2>/dev/null; then
  echo 'pgrep -x sxhkd > /dev/null || sxhkd &' >> "$HOME/.zprofile"
fi

echo "✅ Linux setup complete! Restart your session."
