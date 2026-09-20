local servers = { "pyright", "lua_ls", "ts_ls", "gopls", "clangd" }

return {
	{
		"mason-org/mason.nvim",
		cmd = "Mason",
		opts = {
			ui = { border = "rounded" },
		},
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			if ok_cmp then
				capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
			end

			local server_configs = {

				pyright = {
					capabilities = capabilities,
					settings = {
						python = {
							analysis = {
								autoSearchPaths = true,
								diagnosticMode = "workspace",
								useLibraryCodeForTypes = true,
								typeCheckingMode = "basic",
							},
						},
					},
				},
				ts_ls = {
					capabilities = capabilities,
					settings = {
						typescript = {
							inlayHints = {
								includeInlayParameterNameHints = "all",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = true,
								includeInlayVariableTypeHintsWhenTypeMatchesName = false,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
						javascript = {
							inlayHints = {
								includeInlayParameterNameHints = "all",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = true,
								includeInlayVariableTypeHintsWhenTypeMatchesName = false,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
					},
				},
				gopls = {
					capabilities = capabilities,
					settings = {
						gopls = {
							completeUnimported = true,
							deepCompletion = true,
							matcher = "Fuzzy",
							symbolMatcher = "FastFuzzy",
							semanticTokens = false,
							codelenses = {
								gc_details = false,
								generate = true,
								regenerate_cgo = true,
								tidy = true,
								upgrade_dependency = true,
								vendor = true,
							},
							hints = {
								assignVariableTypes = true,
								compositeLiteralFields = true,
								compositeLiteralTypes = true,
								constantValues = true,
								functionTypeParameters = true,
								parameterNames = true,
								rangeVariableTypes = true,
							},
							analyses = {
								unusedparams = true,
								unusedwrite = true,
								useany = true,
								fieldalignment = false,
								shadow = false,
							},
							staticcheck = true,
							directoryFilters = {
								"-vendor",
								"-node_modules",
								"-.git",
							},
							buildFlags = { "-tags=wireinject" },
						},
					},
				},
				lua_ls = {
					capabilities = capabilities,
					settings = {
						Lua = {
							runtime = { version = "LuaJIT" },
							diagnostics = { globals = { "vim" } },
							workspace = {
								checkThirdParty = false,
								library = {
									vim.env.VIMRUNTIME,
									"${3rd}/luv/library",
								},
							},
							telemetry = { enable = false },
						},
					},
				},
				clangd = {
					capabilities = capabilities,
					cmd = {
						"clangd",
						"--background-index",
						"--clang-tidy",
						"--header-insertion=iwyu",
						"--function-arg-placeholders",
						"--query-driver=**/*",
					},
					init_options = {
						usePlaceholders = true,
						clangdFileStatus = true,
					},
					settings = {
						clangd = {
							fallbackFlags = { "-std=c++17" },
						},
					},
				},
			}

			-- 1. mason-lspconfig 自动配置 Mason 安装的 LSP server
			--    automatic_enable = true → 新安装的 LSP 重启后自动生效
			require("mason-lspconfig").setup({
				ensure_installed = servers,
				automatic_enable = true,
			})

			-- 2. 用户自定义配置合并到默认配置之上
			for _, server in ipairs(servers) do
				vim.lsp.config(server, server_configs[server] or { capabilities = capabilities })
			end

			-- 3. 兜底启用（含非 Mason 安装的系统 LSP）
			vim.lsp.enable(servers)
		end,
	},
}
