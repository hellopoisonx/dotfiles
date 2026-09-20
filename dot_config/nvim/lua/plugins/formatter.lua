local function has(exe)
	return vim.fn.executable(exe) == 1
end

local function prettier()
	if not has("prettier") then
		return nil
	end
	local util = require("formatter.util")
	return {
		exe = "prettier",
		args = { "--stdin-filepath", util.escape_path(util.get_current_buffer_file_path()) },
		stdin = true,
		try_node_modules = true,
	}
end

-- clang-format：C / C++ / Objective-C / CUDA 的统一格式化器
-- 通过 --assume-filename 让 stdin 输入也能匹配项目根目录的 .clang-format 规则
local function clang_format()
	if not has("clang-format") then
		return nil
	end
	local util = require("formatter.util")
	return {
		exe = "clang-format",
		args = { "--assume-filename=" .. util.escape_path(util.get_current_buffer_file_path()) },
		stdin = true,
	}
end

return {
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		event = "VeryLazy",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = {
				"stylua",
				"black",
				"ruff",
				"clang-format",
				"goimports",
				"gofumpt",
				"golangci-lint",
				"shfmt",
				"shellcheck",
				"prettier",
				"eslint_d",
				"markdownlint-cli2",
				"yamllint",
				"actionlint",
			},
			auto_update = false,
			run_on_start = true,
			start_delay = 3000,
		},
	},
	{
		"mhartington/formatter.nvim",
		lazy = false,
		keys = {
			{
				"<leader>fm",
				function()
					local tick = vim.b.changedtick
					vim.cmd("Format")
					-- formatter.nvim 什么都没做（工具缺失或 filetype 无匹配）→ LSP fallback
					if vim.b.changedtick == tick then
						pcall(vim.lsp.buf.format, { async = true })
					end
				end,
				mode = { "n", "v" },
				desc = "格式化当前文件",
			},
		},
		config = function()
			local util = require("formatter.util")

			require("formatter").setup({
				logging = true,
				log_level = vim.log.levels.WARN,
				filetype = {
					lua = {
						function()
							if not has("stylua") then
								return nil
							end
							return {
								exe = "stylua",
								args = {
									"--search-parent-directories",
									"--stdin-filepath",
									util.escape_path(util.get_current_buffer_file_path()),
									"-",
								},
								stdin = true,
							}
						end,
					},
					python = {
						function()
							if not has("black") then
								return nil
							end
							return { exe = "black", args = { "--quiet", "-" }, stdin = true }
						end,
					},
					go = {
						function()
							if not has("gofumpt") then
								return nil
							end
							return {
								exe = "gofumpt",
								args = {},
								stdin = true,
							}
						end,
					},
					sh = {
						function()
							if not has("shfmt") then
								return nil
							end
							return {
								exe = "shfmt",
								args = { "-filename", util.escape_path(util.get_current_buffer_file_path()) },
								stdin = true,
							}
						end,
					},
					c = { clang_format },
					cpp = { clang_format },
					objc = { clang_format },
					objcpp = { clang_format },
					cuda = { clang_format },
					javascript = { prettier },
					javascriptreact = { prettier },
					typescript = { prettier },
					typescriptreact = { prettier },
					json = { prettier },
					jsonc = { prettier },
					css = { prettier },
					scss = { prettier },
					html = { prettier },
					markdown = { prettier },
					yaml = { prettier },
					["*"] = {
						-- LSP format + trailing whitespace 合并为一个 formatter
						-- LSP 先修改 buffer，然后返回 tailing-whitespace 定义让管道读取已格式化的内容
						function()
							local clients = vim.lsp.get_clients({ bufnr = 0 })
							if #clients > 0 then
								pcall(vim.lsp.buf.format, { async = false, timeout_ms = 3000 })
							end
							return require("formatter.filetypes.any").remove_trailing_whitespace()
						end,
					},
				},
			})
		end,
	},
}
