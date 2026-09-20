return {
	{
		"nvim-flutter/flutter-tools.nvim",
		lazy = false,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"stevearc/dressing.nvim", -- 可选，为 vim.ui.select 提供更好的 UI
		},
		config = function()
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			if ok_cmp then
				capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
			end

			require("flutter-tools").setup({
				-- 开启 FVM 支持，优先使用 <workspace>/.fvm/flutter_sdk
				fvm = true,

				ui = {
					border = "rounded",
					notification_style = "native",
				},

				decorations = {
					statusline = {
						app_version = false,
						device = false,
						project_config = false,
					},
				},

				debugger = {
					enabled = false,
					exception_breakpoints = {},
					evaluate_to_string_in_debug_views = true,
				},

				widget_guides = {
					enabled = false,
				},

				closing_tags = {
					highlight = "ErrorMsg",
					prefix = ">",
					priority = 10,
					enabled = true,
				},

				dev_log = {
					enabled = true,
					notify_errors = true,
					open_cmd = "15split",
					focus_on_open = true,
				},

				dev_tools = {
					autostart = false,
					auto_open_browser = false,
				},

				outline = {
					open_cmd = "30vnew",
					auto_open = false,
				},

				lsp = {
					capabilities = capabilities,
					on_attach = function(client, bufnr)
						client = client -- suppress unused warning
						-- 启用 LSP 色彩高亮（Neovim >= 0.12 原生支持）
						local color_ok = pcall(vim.lsp.document_color.enable, true, { bufnr = bufnr })
						if not color_ok then
							-- Neovim < 0.12 回退
							pcall(vim.lsp.buf.document_color, { bufnr = bufnr })
						end
					end,
					settings = {
						showTodos = true,
						completeFunctionCalls = true,
						renameFilesWithClasses = "prompt",
						enableSnippets = true,
						updateImportsOnRename = true,
					},
				},
			})

			-- 加载 Telescope Flutter 扩展，支持 FVM 版本切换等功能
			local ok_telescope, telescope = pcall(require, "telescope")
			if ok_telescope then
				pcall(telescope.load_extension, "flutter")
			end
		end,
	},


}
