#!/bin/sh

mkdir -p ~/.config/nvim
mkdir -p ~/.config/kitty

stow -R zsh
stow -R --target="$HOME"/.config/nvim nvim
stow -R --target="$HOME"/.config/kitty kitty
stow -R --target="$HOME"/.config picom
stow -R --target="$HOME"/.config modprobed-db
