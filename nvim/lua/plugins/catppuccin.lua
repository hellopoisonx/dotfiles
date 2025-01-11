return {
	"catppuccin/nvim",
	lazy = false,
	priority = 1000,
	name = "catppuccin",
	opts = {
		integrations = {
			aerial = true,
			alpha = true,
			cmp = true,
			dashboard = true,
			flash = true,
			fzf = true,
			grug_far = true,
			gitsigns = true,
			headlines = true,
			illuminate = true,
			indent_blankline = { enabled = true },
			leap = true,
			lsp_trouble = true,
			mason = true,
			markdown = true,
			mini = true,
			native_lsp = {
				enabled = true,
				underlines = {
					errors = { "undercurl" },
					hints = { "undercurl" },
					warnings = { "undercurl" },
					information = { "undercurl" },
				},
			},
			noice = true,
			notify = true,
			semantic_tokens = true,
			treesitter = true,
			treesitter_context = true,
		},
	},
	config = function()
		vim.cmd([[colorscheme catppuccin]])
	end,
}
