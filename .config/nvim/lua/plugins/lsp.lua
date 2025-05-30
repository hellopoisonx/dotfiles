return {
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		dependencies = {
			"onsails/lspkind.nvim",
		},
		config = function()
			vim.lsp.inlay_hint.enable(true)
			require("lspkind").init({
				mode = "symbol_text",
				preset = "default",
				symbol_map = {
					Text = "󰉿",
					Method = "󰆧 ",
					Function = "󰊕",
					Constructor = "",
					Field = "󰜢",
					Variable = "󰀫",
					Class = "󰠱",
					Interface = "",
					Module = "",
					Property = "󰜢",
					Unit = "󰑭",
					Value = "󰎠",
					Enum = "",
					Keyword = "󰌋",
					Snippet = "",
					Color = "󰏘",
					File = "󰈙",
					Reference = "󰈇",
					Folder = "󰉋",
					EnumMember = "",
					Constant = "󰏿",
					Struct = "󰙅",
					Event = "",
					Operator = "󰆕",
					TypeParameter = "",
				},
			})
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			require("lspconfig").cmake.setup({
				capabilities = capabilities,
			})
			require("lspconfig").clangd.setup({
				capabilities = capabilities,
			})
			require("lspconfig").gopls.setup({
				capabilities = capabilities,
			})
			require("lspconfig").pyright.setup({
				capabilities = capabilities,
			})
			require("lspconfig").bashls.setup({
				capabilities = capabilities,
				filetypes = { "bash", "sh", "zsh", ".zshrc" },
			})
			require("lspconfig").ts_ls.setup({
				capabilities = capabilities,
			})
			require("lspconfig").lua_ls.setup({
				capabilities = capabilities,
				settings = {
					Lua = {
						workspace = {
							checkThirdParty = false,
						},
						codeLens = {
							enable = true,
						},
						completion = {
							callSnippet = "Replace",
						},
						doc = {
							privateName = { "^_" },
						},
						hint = {
							enable = true,
							setType = true,
							paramType = true,
							paramName = "All",
							semicolon = "All",
							arrayIndex = "All",
						},
					},
				},
			})
		end,
	},
	{
		"nvimdev/lspsaga.nvim",
		lazy = true,
		event = "LspAttach",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {},
	},
}
