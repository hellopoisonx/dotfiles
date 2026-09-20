return {
	{
		"nvim-mini/mini.files",
		version = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{
				"<leader>fe",
				function()
					if not require("mini.files").close() then
						require("mini.files").open()
					end
				end,
				desc = "打开/关闭文件浏览器",
			},
		},
		init = function()
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1
		end,
		config = function()
			require("mini.files").setup({
				windows = {
					preview = true,
					width_preview = 60,
				},
				filesystem = {
					git_status_hl = true,
				},
				options = {
					use_as_default_explorer = true,
				},
			})
		end,
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function() require("flash").jump() end,
				desc = "Flash 跳转",
			},
			{
				"S",
				mode = { "n", "x", "o" },
				function() require("flash").treesitter() end,
				desc = "Flash Treesitter 跳转",
			},
			{
				"r",
				mode = "o",
				function() require("flash").remote() end,
				desc = "Flash 远程操作",
			},
			{
				"R",
				mode = { "o", "x" },
				function() require("flash").treesitter_search() end,
				desc = "Flash Treesitter 搜索",
			},
			{
				"<c-s>",
				mode = { "c" },
				function() require("flash").toggle() end,
				desc = "切换 Flash 搜索标签",
			},
		},
		opts = {
			jump = {
				-- 只有一个匹配时自动跳转，无需按确认键
				autojump = true,
			},
			modes = {
				-- f/F/t/T 增强：多行匹配时显示跳转标签
				char = {
					jump_labels = true,
				},
			},
		},
	},
	{
		"numToStr/Comment.nvim",
		keys = { "gcc", "gc", "gbc", "gb" },
		opts = {},
	},
	{
		"nvzone/floaterm",
		dependencies = { "nvzone/volt" },
		cmd = "FloatermToggle",
		keys = {
			{ "<C-/>", "<cmd>FloatermToggle<CR>", mode = { "n", "t" }, desc = "切换浮动终端" },
			{ "<C-_>", "<cmd>FloatermToggle<CR>", mode = { "n", "t" }, desc = "切换浮动终端" },
		},
		opts = {
			border = true,
			size = { h = 75, w = 80 },
			terminals = {
				{ name = "Terminal" },
				{ name = "OMP", cmd = "omp" },
			},
		},
	},
	{
		"romgrk/barbar.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VeryLazy",
		keys = {
			{ "<A-h>", "<cmd>BufferPrevious<CR>", desc = "上一个 Buffer" },
			{ "<A-l>", "<cmd>BufferNext<CR>", desc = "下一个 Buffer" },
			{ "<leader>bd", "<cmd>BufferClose<CR>", desc = "关闭当前 Buffer" },
		},
		init = function()
			vim.g.barbar_auto_setup = false
		end,
		opts = {
			animation = false,
			icons = { separator = { left = "", right = "" } },
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = function()
			if vim.fn.executable("tree-sitter") == 1 then
				vim.cmd("TSUpdate")
			end
		end,
		config = function()
			local parsers = {
				"bash",
				"go",
				"gomod",
				"gosum",
				"json",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"python",
				"query",
				"vim",
				"vimdoc",
				"yaml",
				"dart",
			}

			require("nvim-treesitter").setup({
				install_dir = vim.fn.stdpath("data") .. "/site",
			})

			if vim.fn.executable("tree-sitter") == 1 then
				require("nvim-treesitter").install(parsers)
			else
				vim.schedule(function()
					vim.notify(
						"nvim-treesitter: 未检测到 tree-sitter CLI，请先执行 `sudo pacman -S tree-sitter`",
						vim.log.levels.WARN
					)
				end)
			end

			local group = vim.api.nvim_create_augroup("UserTreesitterSetup", { clear = true })

			vim.api.nvim_create_autocmd("FileType", {
				group = group,
				pattern = {
					"bash",
					"go",
					"gomod",
					"gosum",
					"json",
					"lua",
					"luadoc",
					"markdown",
					"python",
					"query",
					"vim",
					"vimdoc",
					"yaml",
					"dart",
				},
				callback = function(args)
					pcall(vim.treesitter.start, args.buf)
				end,
			})

			vim.api.nvim_create_autocmd("FileType", {
				group = group,
				pattern = { "go", "gomod", "lua", "python", "yaml", "json", "vim" },
				callback = function(args)
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown" },
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		opts = {
			completions = { lsp = { enabled = true } },
			heading = { border = true },
			code = { border = "thin" },
		},
	},
	{
		"selimacerbas/markdown-preview.nvim",
		dependencies = { "selimacerbas/live-server.nvim" },
		cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewRefresh" },
		keys = {
			{ "<leader>mps", "<cmd>MarkdownPreview<CR>", desc = "Markdown: 开始预览" },
			{ "<leader>mpS", "<cmd>MarkdownPreviewStop<CR>", desc = "Markdown: 停止预览" },
			{ "<leader>mpr", "<cmd>MarkdownPreviewRefresh<CR>", desc = "Markdown: 刷新预览" },
		},
		config = function()
			require("markdown_preview").setup({
				instance_mode = "takeover",
				port = 0,
				open_browser = true,
				default_theme = "dark",
				debounce_ms = 300,
			})
		end,
	},
}
