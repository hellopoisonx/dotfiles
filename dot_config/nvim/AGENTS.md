# Neovim 配置维护指南

本目录是用户的 Neovim 配置，回复与生成文档请优先使用简体中文。

## 主要信息

- Nvim version: `0.12.4`
- 配置总览、快捷键、插件说明请以 `README.md` 为准。
- 官方文档: `https://neovim.io/doc/`
- 入口文件：`init.lua`
- 插件管理：`lazy.nvim`
- 插件规格目录：`lua/plugins/`
- 核心配置目录：`lua/core/`
- Leader 键：`<Space>`
- 当前目标：轻量、模块化、接近 IDE 的 Go / Python / Lua / Shell / Markdown 开发环境。

## 修改约定

- 新插件优先按职责放入 `lua/plugins/*.lua`：
  - LSP / 补全 / 格式化：`lsp.lua`、`completion.lua`、`formatter.lua`
  - 诊断 / lint：`diagnostics.lua`
  - Git：`git.lua`
  - 编辑体验：`editor.lua`、`editing.lua`、`todo.lua`
  - UI：`ui.lua`、`snacks.lua`、`statusline.lua`
  - 任务：`tasks.lua`
  - Session：`session.lua`
- 修改快捷键后必须同步更新 `README.md`。
- 新增外部工具时，优先同步到 `lua/plugins/formatter.lua` 的 `mason-tool-installer.nvim` 配置。
- 修改 Lua 配置后建议执行：

```bash
~/.local/share/nvim/mason/bin/stylua init.lua lua/**/*.lua
nvim --headless "+lua print('config loaded')" +qa
```

## 当前关键插件

- `folke/lazy.nvim`
- `catppuccin/nvim`
- `nvim-mini/mini.files`
- `folke/flash.nvim`
- `nvim-telescope/telescope.nvim`
- `neovim/nvim-lspconfig`
- `hrsh7th/nvim-cmp`
- `mhartington/formatter.nvim`
- `mfussenegger/nvim-lint`
- `folke/trouble.nvim`
- `folke/snacks.nvim`
- `folke/todo-comments.nvim`
- `lewis6991/gitsigns.nvim`
- `stevearc/overseer.nvim`
- `rmagatti/auto-session`
- `nvim-mini/mini.statusline`
- `folke/which-key.nvim`
