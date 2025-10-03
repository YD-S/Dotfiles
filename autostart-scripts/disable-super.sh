#!/bin/bash
# Disable GNOME overlay key so sxhkd can use Super
gsettings set org.gnome.mutter overlay-key ''
gsettings set org.gnome.desktop.lockdown disable-lock-screen true
gsettings set org.gnome.desktop.session idle-delay 0