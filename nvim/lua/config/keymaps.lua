-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
LazyVim.safe_keymap_set({ "i", "t" }, "jj", "<ESC>", { remap = false })
