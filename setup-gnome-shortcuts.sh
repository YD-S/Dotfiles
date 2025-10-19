#!/bin/bash

# Define base path for custom keybindings
BASE_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

# Define apps and shortcuts
declare -A APPS
APPS["firefox"]="gtk-launch firefox.desktop|<Super>b"
APPS["code"]="gtk-launch code.desktop|<Super>v"
APPS["alacritty"]="gtk-launch Alacritty.desktop|<Super>Return"

# Build the keybinding list
KEYBINDINGS=()
for APP in "${!APPS[@]}"; do
    KEYBINDINGS+=("$BASE_PATH/$APP/")
done

# Register all keybindings in GNOME
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$(printf "['%s', '%s', '%s']" "${KEYBINDINGS[@]}")"

# Create each keybinding
for APP in "${!APPS[@]}"; do
    IFS='|' read -r CMD SHORTCUT <<< "${APPS[$APP]}"
    PATH="$BASE_PATH/$APP/"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$PATH name "$APP"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$PATH command "$CMD"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$PATH binding "$SHORTCUT"
done

echo "✅ GNOME shortcuts created successfully!"
