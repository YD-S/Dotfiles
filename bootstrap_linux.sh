#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${1:-$HOME/dotfiles}"

echo "🚀 Setting up Linux from $DOTFILES_DIR"

# --- 1) Add GRUB Customizer PPA and update system ---
sudo add-apt-repository -y ppa:danielrichter2007/grub-customizer
sudo add-apt-repository -y ppa:aslatter/ppa
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential curl wget ca-certificates \
  libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
  libffi-dev libncurses5-dev libncursesw5-dev xz-utils tk-dev \
  liblzma-dev libxml2 libxmlsec1 pkg-config git firefox grub-customizer \
  sxhkd jq alacritty wireguard wireguard-tools autoconf gcc make \
  libpam0g-dev libcairo2-dev libfontconfig1-dev libxcb-composite0-dev \
  libev-dev libx11-xcb-dev libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev \
  libxcb-image0-dev libxcb-util0-dev libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev \
  libjpeg-dev libgif-dev libtool xutils-dev rofi xautolock

# --- 2) Install JetBrains Toolbox ---
echo "📦 Installing JetBrains Toolbox..."

TOOLBOX_DIR="$HOME/.local/jetbrains-toolbox"
TOOLBOX_BIN="$TOOLBOX_DIR/jetbrains-toolbox"
TOOLBOX_TMP="/tmp/jetbrains-toolbox"
mkdir -p "$TOOLBOX_DIR" "$TOOLBOX_TMP"

# Get latest version + correct download link
TOOLBOX_JSON=$(curl -s "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release")
DOWNLOAD_URL=$(echo "$TOOLBOX_JSON" | jq -r '.TBA[0].downloads.linux.link')
VERSION=$(echo "$TOOLBOX_JSON" | jq -r '.TBA[0].version')

if [[ -z "$DOWNLOAD_URL" || "$DOWNLOAD_URL" == "null" ]]; then
  echo "❌ Could not retrieve JetBrains Toolbox download URL"
  exit 1
fi

echo "⬇️  Downloading JetBrains Toolbox v$VERSION from:"
echo "$DOWNLOAD_URL"

curl -L "$DOWNLOAD_URL" -o "$TOOLBOX_DIR/toolbox.tar.gz"

# Extract and install
tar -xzf "$TOOLBOX_DIR/toolbox.tar.gz" -C "$TOOLBOX_TMP"
EXTRACTED=$(find "$TOOLBOX_TMP" -type f -name "jetbrains-toolbox" | head -n1)

if [[ -x "$EXTRACTED" ]]; then
  cp "$EXTRACTED" "$TOOLBOX_BIN"
  chmod +x "$TOOLBOX_BIN"
  ln -sf "$TOOLBOX_BIN" "$HOME/.local/bin/jetbrains-toolbox"
  echo "✅ JetBrains Toolbox installed to $TOOLBOX_BIN"
else
  echo "❌ Failed to find jetbrains-toolbox binary after extraction"
  exit 1
fi

# Clean up
rm -rf "$TOOLBOX_TMP" "$TOOLBOX_DIR/toolbox.tar.gz"

echo "✅ JetBrains Toolbox installed at $TOOLBOX_BIN"

export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/share/pkgconfig:/usr/lib/pkgconfig

git clone https://github.com/Raymo111/i3lock-color.git /tmp/i3lock-color
cd /tmp/i3lock-color
./install-i3lock-color.sh


git clone https://github.com/betterlockscreen/betterlockscreen.git /tmp/betterlockscreen
sudo cp /tmp/betterlockscreen/betterlockscreen /usr/local/bin/
rm -rf /tmp/betterlockscreen

# BetterLockScreen Setup
mkdir -p "$HOME/Pictures"
convert -size 1920x1080 xc:black "$HOME/Pictures/lockscreen.png"
betterlockscreen -u "$HOME/Pictures/lockscreen.png"

# --- 3) Install Linuxbrew/Homebrew ---
if ! command -v brew >/dev/null 2>&1; then
  echo "📦 Installing Linuxbrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.zshrc"
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# --- 4) Install packages from Brewfile ---
if [ -f "$DOTFILES_DIR/Brewfile_linux" ]; then
  brew bundle --file="$DOTFILES_DIR/Brewfile_linux"
fi

# --- 5) Stow dotfiles ---
mkdir -p "$HOME/.config/alacritty"
mkdir -p "$HOME/.config/sxhkd"
mkdir -p "$HOME/.config/rofi"
mkdir -p "$HOME/.config/autostart"
mkdir -p "$HOME/.config/autostart-scripts"
cd "$DOTFILES_DIR"

# Alacritty → ~/.config/alacritty
stow --target="$HOME/.config/alacritty" alacritty

# Starship → ~/.config/starship
stow --target="$HOME/.config/" starship

# Keybinds (sxhkd) → ~/.config/sxhkd
stow --target="$HOME/.config/sxhkd" keybinds

# betterlockscreen
stow --target="$HOME/.config/" betterlockscreen

#rofi
stow --target="$HOME/.config/rofi" rofi

#autostart
stow --target="$HOME/.config/autostart" autostart

#autostart
stow --target="$HOME/.config/autostart-scripts" autostart-scripts

# Zsh config → ~/.zshrc
ln -sf "$DOTFILES_DIR/zsh/.zshrc_linux" "$HOME/.zshrc"

# --- 6) Set Zsh as default shell ---
if [[ "$SHELL" != "$(which zsh)" ]]; then
  chsh -s "$(which zsh)"
fi

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install zsh plugins
mkdir -p "$ZSH/plugins"
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH/plugins/zsh-syntax-highlighting

# Configure plugins in .zshrc
sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"


# --- 7) Install NVM + Node.js ---
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm install --lts
nvm alias default lts/*

# --- 8) Install Pyenv + Set Python version ---
if ! command -v pyenv >/dev/null 2>&1; then
  brew install pyenv || curl https://pyenv.run | bash
fi
echo "Setting Python 3.13.5 as global default..."
pyenv install 3.13.5
pyenv global 3.13.5

# --- 9) Autostart JetBrains Toolbox ---
JB_BIN="$TOOLBOX_BIN"
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

# --- 10) WireGuard setup ---
sudo apt install -y wireguard wireguard-tools
for conf in /etc/wireguard/*.conf; do
  [ -e "$conf" ] || continue
  name="$(basename "$conf" .conf)"
  sudo systemctl enable --now "wg-quick@$name"
done

# --- 11) sxhkd autostart ---
AUTOSTART_DIR="$HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"

if [ ! -f "$AUTOSTART_DIR/sxhkd.desktop" ]; then
  cat > "$AUTOSTART_DIR/sxhkd.desktop" <<EOF
[Desktop Entry]
Type=Application
Exec=sxhkd
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=SXHKD
Comment=Start sxhkd hotkey daemon
Icon=keyboard
EOF
fi

if ! grep -q "sxhkd" "$HOME/.zprofile" 2>/dev/null; then
  echo 'pgrep -x sxhkd > /dev/null || sxhkd &' >> "$HOME/.zprofile"
fi

# --- 12) Install JetBrains Nerd Font manually ---
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -o JetBrainsMono.zip
rm JetBrainsMono.zip
fc-cache -fv

# --- 13) Add autolock to autostart
AUTOSTART_DIR="$HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"

if [ ! -f "$AUTOSTART_DIR/betterlockscreen-autolock.desktop" ]; then
  cat > "$AUTOSTART_DIR/betterlockscreen-autolock.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=BetterLockscreen Auto Lock
Exec=xautolock -time 1 -locker "betterlockscreen -l" -detectsleep
X-GNOME-Autostart-enabled=true
Terminal=false
Comment=Automatically locks screen after 1 minute idle
EOF
fi


echo "✅ Linux setup complete! Restart your session."
