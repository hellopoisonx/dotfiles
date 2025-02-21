#!/bin/sh
stow -R --target="$HOME" zsh
stow -R --target="$HOME/.config" .config
stow -R --target="$HOME/.local" .local
