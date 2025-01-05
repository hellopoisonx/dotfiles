#!/bin/sh

mkdir -p ~/.config/nvim
mkdir -p ~/.config/kitty
mkdir -p ~/.config/ranger

stow -R zsh
stow -R --target="$HOME"/.config/nvim nvim
stow -R --target="$HOME"/.config/kitty kitty
stow -R --target="$HOME"/.config/ranger ranger
stow -R --target="$HOME"/.config picom
stow -R --target="$HOME"/.config modprobed-db
