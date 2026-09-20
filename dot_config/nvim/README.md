# Neovim 配置

这是一个基于 `lazy.nvim` 的模块化 Neovim 配置，目标是提供轻量、清晰、接近 IDE 的 Go / Python / Lua / Shell / Markdown 开发体验。

## 项目速览

> 本节由原 `AGENTS.md` 迁移并补充，作为人类读者和编码代理都可参考的配置总览。

- 入口文件：`init.lua`
- 插件管理器：[`folke/lazy.nvim`](https://github.com/folke/lazy.nvim)
- Leader 键：`<Space>`
- 主题：[`catppuccin/nvim`](https://github.com/catppuccin/nvim)，默认 `catppuccin-mocha`
- LSP：`gopls`、`pyright`、`lua_ls`、`clangd`
- 主要功能：文件浏览器、Telescope 搜索、LSP、补全、格式化、Lint、Git hunk、lazygit、诊断面板、任务运行、Session 恢复、浮动终端、Markdown 渲染、快捷键提示

### 主要插件索引

- [mini.files](https://github.com/nvim-mini/mini.files)：浮动文件浏览器
- [flash.nvim](https://github.com/folke/flash.nvim)：快速跳转（`s`/`S` 跨行标签，增强 `f`/`F`/`t`/`T`）
- [floaterm](https://github.com/nvzone/floaterm)：浮动终端；进入浮动终端后预留 `Ctrl+l/a/e/k` 给 shell 使用
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)：LSP 配置
- [formatter.nvim](https://github.com/mhartington/formatter.nvim)：格式化
- [Comment.nvim](https://github.com/numtostr/comment.nvim)：注释
- [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim)：Markdown 渲染
- [markdown-preview.nvim](https://github.com/selimacerbas/markdown-preview.nvim)：Markdown 浏览器预览（含 Mermaid 支持）
- [barbar.nvim](https://github.com/romgrk/barbar.nvim)：Buffer 标签栏
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)：搜索 / Picker
- [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)：Git hunk / blame
- [lazygit.nvim](https://github.com/kdheepak/lazygit.nvim)：lazygit 浮动终端集成
- [nvim-lint](https://github.com/mfussenegger/nvim-lint)：异步 lint
- [trouble.nvim](https://github.com/folke/trouble.nvim)：诊断 / quickfix / LSP 列表
- [snacks.nvim](https://github.com/folke/snacks.nvim)：大文件保护 (bigfile) / 作用域高亮 (dim) / 快速渲染 (quickfile) / 作用域文本对象 (scope) / LSP 文件重命名 (rename) / 平滑滚动 (scroll) / 图片查看 (image) / Zen 专注模式 (zen)
- [todo-comments.nvim](https://github.com/folke/todo-comments.nvim)：高亮 TODO / FIX / NOTE 等注释标记
- [nvim-autopairs](https://github.com/windwp/nvim-autopairs)：自动括号
- [overseer.nvim](https://github.com/stevearc/overseer.nvim)：任务运行器
- [nvim-surround](https://github.com/kylechui/nvim-surround)：Surround 操作
- [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)：缩进线
- [mini.statusline](https://github.com/nvim-mini/mini.statusline)：轻量状态栏
- [dropbar.nvim](https://github.com/Bekaboo/dropbar.nvim)：winbar 面包屑（LSP / Treesitter / Path 自动 fallback）
- [auto-session](https://github.com/rmagatti/auto-session)：Session 管理
- [pi.nvim](https://github.com/pablopunk/pi.nvim)：Neovim 内通过 pi CLI 与 AI 交互


## 环境要求

- Neovim `>= 0.12`，当前配置使用了新版 `vim.lsp.config()` / `vim.lsp.enable()` API
- Git `>= 2.19`
- 推荐安装 Nerd Font，保证图标显示正常
- 推荐命令行工具：
  - `rg`：Telescope 全文搜索
  - `fd`：Telescope 文件查找体验更好
  - `tree-sitter`：Treesitter parser 安装与更新

## 目录结构

```text
init.lua
lua/
  core/
    options.lua      # 基础选项、诊断显示配置、inlay_hint 启用
    keymaps.lua      # 全局快捷键
    autocmds.lua     # 自动命令、LSP 快捷键、自动保存
  plugins/
    completion.lua   # nvim-cmp / LuaSnip 补全
    diagnostics.lua  # nvim-lint / trouble.nvim
    editing.lua      # autopairs / surround / indent guides
    editor.lua       # 文件浏览器、flash 跳转、注释、终端、buffer、treesitter、markdown
    formatter.lua    # formatter.nvim / mason-tool-installer
    git.lua          # gitsigns.nvim
    go.lua           # go.nvim (Go 开发)
    lsp.lua          # mason / lspconfig
    session.lua      # auto-session
    snacks.lua       # snacks.nvim (bigfile/dim/quickfile/scope/rename/scroll)
    statusline.lua   # mini.statusline
    tasks.lua        # overseer.nvim
    telescope.lua    # Telescope 搜索
    todo.lua         # todo-comments.nvim
    ui.lua           # 主题、通知、Noice UI、which-key
    pi.lua           # pi.nvim AI 交互
lazy-lock.json       # lazy.nvim 插件锁定文件
```

## 插件栈概览

### 核心

- 插件管理：`folke/lazy.nvim`
- 主题：`catppuccin/nvim`，默认 `catppuccin-mocha`
- UI：`noice.nvim`、`nvim-notify`、`barbar.nvim`、`which-key.nvim`

- LSP：`nvim-lspconfig`、`mason.nvim`、`mason-lspconfig.nvim`，LSP UI 使用 vim.lsp.buf.* 原生 + trouble.nvim 诊断面板
- Go 开发：[`ray-x/go.nvim`](https://github.com/ray-x/go.nvim)（gopls 管理、测试、格式化、代码生成、Tag 管理等）
- 补全：`nvim-cmp`、`cmp-nvim-lsp`、`cmp-buffer`、`cmp-path`
- Snippet：`LuaSnip`、`friendly-snippets`
- 格式化：`formatter.nvim`
- 工具安装：`mason-tool-installer.nvim`

默认 LSP：

- `gopls`（由 go.nvim 管理）
- `pyright`
- `lua_ls`
- `clangd`（C / C++ / Objective-C / CUDA）

默认格式化工具：

- Lua：`stylua`
- Python：`black`
- Go：`gofumpt`（通过 formatter.nvim，手动触发）
- Shell：`shfmt`
- C / C++ / Objective-C / CUDA：`clang-format`（通过 formatter.nvim；本配置根目录附带 LLVM 风格 `.clang-format`，各项目可自带规则覆盖）
- JS / TS / JSON / CSS / HTML / Markdown / YAML：`prettier`
### 开发闭环与编辑体验插件

已配置：
- Go：`ray-x/go.nvim`（gopls、测试、覆盖率、代码生成、Tag、文档、DAP 调试）
- Git：`lewis6991/gitsigns.nvim`
- Lint：`mfussenegger/nvim-lint`
- 诊断面板：`folke/trouble.nvim`
- 自动括号：`windwp/nvim-autopairs`
- 任务运行器：`stevearc/overseer.nvim`
- Surround 操作：`kylechui/nvim-surround`
- Undo Tree：`jiaoshijie/undotree`
- 缩进线：`lukas-reineke/indent-blankline.nvim`
- Session 管理：`rmagatti/auto-session`
- 快捷键提示：`folke/which-key.nvim`
- 跳转：`folke/flash.nvim`（跨行标签跳转 + 增强 `f`/`F`/`t`/`T`）
- 状态栏：`nvim-mini/mini.statusline`
- 大文件保护 / 作用域 / 平滑滚动 / 文件重命名 / 图片查看 / Zen 专注模式：`folke/snacks.nvim`
- 注释高亮：`folke/todo-comments.nvim`

`mason-tool-installer` 同时补充安装常用 lint 工具：

- `ruff`
- `golangci-lint`
- `shellcheck`
- `eslint_d`
- `markdownlint-cli2`
- `yamllint`
- `actionlint`

## 快捷键

Leader 键：`<Space>`

### 常用

| 快捷键       | 功能                                |
| ------------ | ----------------------------------- |
| `jj`         | Insert / Terminal 模式退出到 Normal |
| `q`          | 关闭当前窗口                        |
| `<C-i>`      | 重新加载当前文件并同步 LSP 索引          |
| `<Esc>`      | 清除搜索高亮                        |
| `<leader>fm` | 格式化当前文件                      |
| `<leader>?`  | 显示当前 Buffer 快捷键              |
| `<leader>u`  | 打开/关闭 Undo Tree                    |

### Pi / AI

| 快捷键       | 功能                   |
| ------------ | ---------------------- |
| `<leader>ai` | Pi: 提问 (当前 Buffer)  |
| `<leader>ai` | Pi: 提问 (选区，Visual) |
| `<leader>ac` | Pi: 取消当前请求       |
| `<leader>al` | Pi: 查看会话日志       |

### 窗口 / 标签页

| 快捷键        | 功能          |
| ------------- | ------------- |
| `sv`          | 垂直分屏      |
| `sh`          | 水平分屏      |
| `<C-h/j/k/l>` | 窗口间移动    |
| `<leader>=`   | 平衡窗口大小  |
| `<A-h>`       | 上一个 Buffer |
| `<A-l>`       | 下一个 Buffer |
| `<leader>bd`  | 关闭当前 Buffer |
| `<leader>tn`  | 新建标签页    |
| `<leader>tc`  | 关闭标签页    |

### 文件 / 搜索

| 快捷键       | 功能                   |
| ------------ | ---------------------- |
| `<leader>fe` | 打开/关闭文件浏览器    |
| `<leader>ff` | Telescope 查找文件     |
| `<leader>fg` | Telescope 全文搜索     |
| `<leader>fs` | 搜索光标下单词         |
| `<leader>fb` | 查找 Buffer            |
| `<leader>fh` | 查找帮助               |
| `s`          | Flash 跨行标签跳转           |
| `S`          | Flash Treesitter 作用域跳转  |
| `r`          | Flash 远程操作 (operator-pending) |
| `R`          | Flash Treesitter 搜索 (operator-pending) |
| `<c-s>`      | 搜索时切换 Flash 标签 (cmdline) |
| `f` / `F` / `t` / `T` | Flash 增强单行跳转（多行时显示标签） |

### 终端

| 快捷键            | 功能             |
| ----------------- | ---------------- |
| `<leader>t`       | 底部打开内置终端 |
| `<C-/>` / `<C-_>` | 切换浮动终端     |

### LSP / 诊断

| 快捷键       | 功能                   |
| ------------ | ---------------------- |
| `K`          | 悬浮文档               |
| `gd`         | Telescope 选择并跳转定义 |
| `gi`         | Telescope 选择并跳转实现 |
| `gI`         | Go 文件：跳转接口实现；其他文件：跳转类型定义 |
| `gr`         | Telescope 查找并跳转引用 |
| `<leader>cr` | 符号重命名             |
| `<leader>ca` | Code Action            |
| `[d` / `]d`  | 上一个 / 下一个诊断    |
| `<leader>e`  | 打开当前行诊断浮窗     |
| `<leader>q`  | 诊断写入 location list |
| `<leader>cl` | 手动 lint 当前文件     |
| `<leader>rn` | Snacks LSP 文件重命名   |
| `<leader>;`  | dropbar：Pick 模式选择面包屑符号 |
| `[;`         | dropbar：跳到当前 context 起点 |
| `];`         | dropbar：选下一个 context |
LSP 位置类跳转使用 Telescope picker，选择条目并按 `<CR>` 即可跳转；如果 Telescope 不可用，会自动回退到 Neovim 内置 LSP 跳转。

### Snacks 增强功能

| 快捷键       | 功能                       |
| ------------ | -------------------------- |
| `ii`         | 选中当前缩进作用域（内部） |
| `ai`         | 选中当前缩进作用域（完整） |
| `[i`         | 跳转到作用域顶部           |
| `]i`         | 跳转到作用域底部           |
| `<leader>zh` | 图片悬浮预览 (Snacks image)|
| `<leader>zz` | Zen 专注模式               |
| `<leader>zZ` | Zoom 全屏                  |

### Trouble 诊断面板

| 快捷键       | 功能                   |
| ------------ | ---------------------- |
| `<leader>xx` | 打开/关闭工作区诊断    |
| `<leader>xX` | 打开/关闭当前文件诊断  |
| `<leader>xs` | 文档符号               |
| `<leader>xl` | LSP 定义 / 引用 / 实现 |
| `<leader>xq` | Quickfix 列表          |
| `<leader>xL` | Location 列表          |

### Git / Gitsigns

| 快捷键       | 功能                     |
| ------------ | ------------------------ |
| `]g` / `[g`  | 下一个 / 上一个 Git hunk |
| `<leader>gs` | 暂存 hunk                |
| `<leader>gr` | 重置 hunk                |
| `<leader>gS` | 暂存当前文件             |
| `<leader>gR` | 重置当前文件             |
| `<leader>gu` | 撤销暂存 hunk            |
| `<leader>gp` | 预览 hunk                |
| `<leader>gb` | 查看当前行 blame         |
| `<leader>gB` | 切换行尾 blame           |
| `<leader>gd` | 当前文件 diff            |
| `<leader>gD` | 与上一版本 diff          |
| `<leader>gg` | 打开 lazygit                |
| `ih`         | Git hunk 文本对象        |

### Go (go.nvim)

前缀键：`<leader>G`

| 快捷键          | 功能                       |
| --------------- | -------------------------- |
| `<leader>Gr`    | 运行当前文件               |
| `<leader>Gb`    | 构建                       |
| `<leader>Gt`    | 运行测试                   |
| `<leader>GT`    | 测试当前文件               |
| `<leader>GF`    | 测试当前函数               |
| `<leader>Gc`    | 测试覆盖率                 |
| `<leader>Gie`   | 自动填充 if err            |
| `<leader>Gif`   | 填充结构体                 |
| `<leader>Gis`   | 填充 switch                |
| `<leader>Gii`   | 实现接口                   |
| `<leader>Git`   | 生成单元测试               |
| `<leader>Gta`   | 添加 struct tag            |
| `<leader>Gtr`   | 移除 struct tag            |
| `<leader>Gdd`   | 查看文档                   |
| `<leader>Gdb`   | 浏览器打开文档             |
| `<leader>Ga`    | 切换测试/实现文件          |
| `<leader>Gav`   | 垂直分屏切换               |
| `<leader>Gas`   | 水平分屏切换               |
| `<leader>Gmt`   | mod tidy                   |
| `<leader>Gmv`   | mod vendor                 |
| `<leader>Gg`    | go get                     |
| `<leader>Gl`    | golangci-lint              |
| `<leader>Gv`    | 漏洞检查 (govulncheck)     |
| `<leader>Gcm`   | 生成注释                   |
| `<leader>Gen`   | 生成 enum                  |
| `<leader>Gjr`   | JSON 转 Struct             |

常用命令：

```vim
:GoRun              " 运行当前文件
:GoTest             " 运行测试
:GoTestFunc         " 测试当前函数
:GoCoverage         " 测试覆盖率
:GoAlt              " 切换测试/实现文件
:GoDoc              " 查看文档
:GoImpl             " 实现接口
:GoIfErr            " 自动填充 if err
:GoModTidy          " mod tidy
:GoLint             " golangci-lint
```

Go 文件使用 `<leader>fm` 或 `:Format` 手动触发 `gofumpt` 格式化（已禁用保存时自动格式化）。

### Overseer 任务

| 快捷键       | 功能               |
| ------------ | ------------------ |
| `<leader>or` | 选择并运行任务     |
| `<leader>oc` | 运行 Shell 命令任务 |
| `<leader>ot` | 切换任务列表       |
| `<leader>oa` | 当前任务操作       |

常用命令：

```vim
:OverseerRun
:OverseerShell
:OverseerToggle
:OverseerTaskAction
```

**自定义任务模板**：

- **Go**: `Go: Run Current File` / `Go: Build Project`（自动查找 go.mod）
- **Flutter (fvm)**: `Flutter: Run` / `Flutter: Build`（支持选择构建目标）
- **Docker**: `Docker: Compose Up` / `Docker: Compose Down`（自动查找 compose 文件）
```

### Session / Auto Session

| 快捷键       | 功能                  |
| ------------ | --------------------- |
| `<leader>sr` | 恢复当前目录 Session  |
| `<leader>ss` | 保存当前目录 Session  |
| `<leader>sf` | 查找 Session          |
| `<leader>sd` | 删除当前目录 Session  |
| `<leader>sD` | 选择并删除 Session    |
| `<leader>st` | 切换 Session 自动保存 |
| `<leader>sp` | 清理孤立 Session      |

Session 会自动保存 / 恢复当前工作目录状态，并排除 `~/`、`~/Downloads`、`/` 等目录，避免在过大的根目录生成无意义 Session。
### Markdown 预览

| 快捷键        | 功能                   |
| ------------- | ---------------------- |
| `<leader>mps` | Markdown: 开始预览     |
| `<leader>mpS` | Markdown: 停止预览     |
| `<leader>mpr` | Markdown: 刷新预览     |

常用命令：

```vim
:MarkdownPreview       " 开始浏览器预览
:MarkdownPreviewStop   " 停止预览
:MarkdownPreviewRefresh " 强制刷新
```

Mermaid 图表在浏览器中渲染为可交互 SVG，支持缩放、平移和导出。


### Which-key / Surround / Autopairs / 缩进线

- `which-key.nvim`：按下 `<leader>` 等前缀键后显示可用快捷键；`<leader>?` 可查看当前 Buffer 的快捷键
- `nvim-autopairs`：Insert 模式自动补全括号、引号等，并集成 `nvim-cmp` 确认补全后的括号处理
- `nvim-surround`：使用默认快捷键，例如：
  - `ys{motion}{char}` 添加 surround
  - `ds{char}` 删除 surround
  - `cs{old}{new}` 修改 surround
- `indent-blankline.nvim`：显示缩进参考线和当前作用域

## Lint 配置

`nvim-lint` 会在以下事件触发：

- `BufWritePost`
- `BufReadPost`
- `InsertLeave`

已配置 filetype：

| Filetype                        | Linter                    |
| ------------------------------- | ------------------------- |
| Python                          | `ruff`                    |
| Go                              | `golangci-lint`           |
| Shell / Bash / Zsh              | `shellcheck`              |
| JavaScript / TypeScript / React | `eslint_d`                |
| Markdown                        | `markdownlint-cli2`       |
| YAML                            | `yamllint`                |
| GitHub Actions YAML             | `actionlint` + `yamllint` |

配置会在运行 lint 前检查 linter 可执行文件是否存在，避免缺少工具时反复报错。

## 常用维护命令

```vim
:Lazy              " 插件管理 UI
:Lazy sync         " 同步/安装/清理插件
:Mason             " 管理 LSP、formatter、linter 等工具
:LspInfo           " 查看 LSP 状态
:checkhealth       " 检查 Neovim 健康状态
:Format            " 格式化当前文件
:Trouble diagnostics toggle
:OverseerRun
:AutoSession search
:WhichKey
```

## 备注

- 当前配置开启了自动保存：编辑后延迟写入文件，并在离开 buffer / 失焦 / 退出前保存。
- `lazy-lock.json` 会锁定插件版本，便于复现环境。
- 如果新增语言支持，通常需要同时补充：LSP、formatter、linter、treesitter parser。
