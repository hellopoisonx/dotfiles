return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		opts = {
			flavour = "mocha",
			transparent_background = false,
			integrations = {
				cmp = true,
				nvimtree = true,
				treesitter = true,
				telescope = true,
				gitsigns = true,
				indent_blankline = { enabled = true },
				native_lsp = { enabled = true },
				dropbar = { enabled = true },
				overseer = true,
			},
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)
			vim.cmd.colorscheme("catppuccin-mocha")
		end,
	},
	{
		"rcarriga/nvim-notify",
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		opts = {
			cmdline = {
				view = "cmdline_popup",
			},
			messages = {
				enabled = true,
				view = "notify",
				view_error = "notify",
				view_warn = "notify",
			},
			notify = {
				enabled = true,
				view = "notify",
			},
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
				signature = {
					enabled = true,
					auto_open = {
						enabled = true,
						trigger = true,
						luasnip = true,
						throttle = 50,
					},
				},
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
				lsp_doc_border = true,
			},
		},
		config = function(_, opts)
			local notify = require("notify")
			notify.setup({
				background_colour = "#1e1e2e",
				render = "wrapped-compact",
				stages = "fade_in_slide_out",
				timeout = 2500,
			})
			vim.notify = notify

			require("noice").setup(opts)
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "显示当前 Buffer 快捷键",
			},
		},
		opts = {
			preset = "modern",
			delay = 300,
			spec = {
				{ "<leader>a", group = "Pi / AI" },
				{ "<leader>c", group = "代码" },
				{ "<leader>f", group = "文件/搜索" },
				{ "<leader>g", group = "Git" },
				{ "<leader>G", group = "Go" },
				{ "<leader>o", group = "任务" },
				{ "<leader>s", group = "Session" },
				{ "<leader>t", group = "标签页/终端" },
				{ "<leader>x", group = "诊断" },
			},
		},
	},
	{
		"nvim-tree/nvim-web-devicons",
		lazy = true,
	},
}
