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
			vim.lsp.config.cmake = {
				capabilities = capabilities,
			}
			vim.lsp.config.lua_ls = {
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
			}
			vim.lsp.enable("lua_ls")
			vim.lsp.config.clangd = {
				capabilities = capabilities,
			}
			vim.lsp.enable("clangd")
			vim.lsp.config.gopls = {
				capabilities = capabilities,
			}
			vim.lsp.enable("gopls")
			vim.lsp.config.pyright = {
				capabilities = capabilities,
			}
			vim.lsp.enable("pyright")
			vim.lsp.config.bashls = {
				capabilities = capabilities,
				filetypes = { "bash", "sh", "zsh", ".zshrc" },
			}
			vim.lsp.enable("bashls")
			vim.lsp.config.ts_ls = {
				capabilities = capabilities,
			}
			vim.lsp.enable("ts_ls")
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
