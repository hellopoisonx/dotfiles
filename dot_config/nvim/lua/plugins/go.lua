return {
	{
		"ray-x/go.nvim",
		dependencies = {
			"ray-x/guihua.lua",
			"neovim/nvim-lspconfig",
		},
		ft = { "go", "gomod" },
		event = { "CmdlineEnter" },
		build = ':lua require("go.install").update_all_sync()',
		keys = {
			-- 运行 / 测试
			{ "<leader>Gr", "<cmd>GoRun<CR>", desc = "Go: 运行当前文件", ft = "go" },
			{ "<leader>Gb", "<cmd>GoBuild<CR>", desc = "Go: 构建", ft = "go" },
			{ "<leader>Gt", "<cmd>GoTest<CR>", desc = "Go: 运行测试", ft = "go" },
			{ "<leader>GT", "<cmd>GoTestFile<CR>", desc = "Go: 测试当前文件", ft = "go" },
			{ "<leader>GF", "<cmd>GoTestFunc<CR>", desc = "Go: 测试当前函数", ft = "go" },
			{ "<leader>Gc", "<cmd>GoCoverage<CR>", desc = "Go: 测试覆盖率", ft = "go" },
			-- 代码生成
			{ "<leader>Gie", "<cmd>GoIfErr<CR>", desc = "Go: 自动填充 if err", ft = "go" },
			{ "<leader>Gif", "<cmd>GoFillStruct<CR>", desc = "Go: 填充结构体", ft = "go" },
			{ "<leader>Gis", "<cmd>GoFillSwitch<CR>", desc = "Go: 填充 switch", ft = "go" },
			{ "<leader>Gii", "<cmd>GoImpl<CR>", desc = "Go: 实现接口", ft = "go" },
			{ "<leader>Git", "<cmd>GoAddTest<CR>", desc = "Go: 生成单元测试", ft = "go" },
			-- Tag 管理
			{ "<leader>Gta", "<cmd>GoAddTag<CR>", desc = "Go: 添加 struct tag", ft = "go" },
			{ "<leader>Gtr", "<cmd>GoRmTag<CR>", desc = "Go: 移除 struct tag", ft = "go" },
			-- 文档 / 导航
			{ "<leader>Gdd", "<cmd>GoDoc<CR>", desc = "Go: 查看文档", ft = "go" },
			{ "<leader>Gdb", "<cmd>GoDocBrowser<CR>", desc = "Go: 浏览器打开文档", ft = "go" },
			{ "<leader>Ga", "<cmd>GoAlt<CR>", desc = "Go: 切换测试/实现文件", ft = "go" },
			{ "<leader>Gav", "<cmd>GoAltV<CR>", desc = "Go: 垂直分屏切换", ft = "go" },
			{ "<leader>Gas", "<cmd>GoAltS<CR>", desc = "Go: 水平分屏切换", ft = "go" },
			-- 模块 / 工具
			{ "<leader>Gmt", "<cmd>GoModTidy<CR>", desc = "Go: mod tidy", ft = "go" },
			{ "<leader>Gmv", "<cmd>GoModVendor<CR>", desc = "Go: mod vendor", ft = "go" },
			{ "<leader>Gg", "<cmd>GoGet<CR>", desc = "Go: go get", ft = "go" },
			{ "<leader>Gl", "<cmd>GoLint<CR>", desc = "Go: golangci-lint", ft = "go" },
			{ "<leader>Gv", "<cmd>GoVulnCheck<CR>", desc = "Go: 漏洞检查", ft = "go" },
			-- 注释 / 重构
			{ "<leader>Gcm", "<cmd>GoCmt<CR>", desc = "Go: 生成注释", ft = "go" },
			{ "<leader>Gen", "<cmd>GoEnum<CR>", desc = "Go: 生成 enum", ft = "go" },
			{ "<leader>Gjr", "<cmd>GoJson2Struct<CR>", desc = "Go: JSON 转 Struct", ft = "go", mode = { "n", "v" } },
		},
		config = function()
			require("go").setup({
				disable_defaults = false,
				lsp_keymaps = false, -- 使用 LspAttach 的统一快捷键
				lsp_cfg = false, -- 禁用 go.nvim 管理 gopls，改用 lsp.lua 原生管理
				lsp_gofumpt = true, -- 使用 gofumpt 格式化
				lsp_on_attach = nil, -- 使用全局 LspAttach autocmd
				lsp_codelens = true, -- 启用 CodeLens
				lsp_inlay_hints = { enable = true },
				lsp_impl = {
					enable = true,
					prefix = '󰜀 ',
					separator = ', ',
					highlight = 'Constant',
				},
				test_runner = "go", -- 默认使用 go test
				run_in_floaterm = false, -- 使用内置终端而不是 floaterm
				trouble = true, -- 集成 trouble.nvim
				luasnip = true, -- 启用 LuaSnip 片段
				diagnostic = {
					underline = true,
					virtual_text = { spacing = 2, prefix = "●" },
					signs = true,
				},
				fmt = {
					gofumpt = true, -- 使用 gofumpt
				},
				icons = {
					breakpoint = "🔴",
					currentpos = "👉",
				},
			})

			-- BufWritePre 自动执行 goimports (已禁用自动格式化，手动 <leader>fm 触发)
			-- local format_grp = vim.api.nvim_create_augroup("GoFormat", { clear = true })
			-- vim.api.nvim_create_autocmd("BufWritePre", {
			-- 	pattern = "*.go",
			-- 	callback = function()
			-- 		require("go.format").goimports()
			-- 	end,
			-- 	group = format_grp,
			-- })
		end,
	},
}
