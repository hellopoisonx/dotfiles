local lint_events = { "BufWritePost", "BufReadPost", "InsertLeave" }

local linters_by_ft = {
	python = { "ruff" },
	-- go 由 gopls 提供实时诊断，golangci-lint 通过 <leader>Gl 手动触发
	sh = { "shellcheck" },
	bash = { "shellcheck" },
	zsh = { "shellcheck" },
	javascript = { "eslint_d" },
	javascriptreact = { "eslint_d" },
	typescript = { "eslint_d" },
	typescriptreact = { "eslint_d" },
	markdown = { "markdownlint-cli2" },
	yaml = { "yamllint" },
	["yaml.ghaction"] = { "actionlint", "yamllint" },
}

local function linter_cmd(lint, name)
	local linter = lint.linters[name]
	if type(linter) == "function" then
		local ok, resolved = pcall(linter)
		if not ok then
			return nil
		end
		linter = resolved
	end

	local cmd = linter and linter.cmd
	if type(cmd) == "function" then
		local ok, resolved = pcall(cmd)
		if not ok then
			return nil
		end
		cmd = resolved
	end

	return cmd
end

local function linter_available(lint, name)
	local cmd = linter_cmd(lint, name)
	return type(cmd) == "string" and vim.fn.executable(cmd) == 1
end

local function linters_for_filetype(filetype)
	local names = {}
	local seen = {}

	local function add_from(ft)
		for _, name in ipairs(linters_by_ft[ft] or {}) do
			if not seen[name] then
				seen[name] = true
				table.insert(names, name)
			end
		end
	end

	add_from(filetype)
	for part in string.gmatch(filetype, "[^.]+") do
		add_from(part)
	end
	add_from("*")

	return names
end

local function try_lint()
	if vim.bo.buftype ~= "" or vim.bo.modifiable == false then
		return
	end

	local ok, lint = pcall(require, "lint")
	if not ok then
		return
	end

	local names = vim.tbl_filter(function(name)
		return linter_available(lint, name)
	end, linters_for_filetype(vim.bo.filetype))

	if #names > 0 then
		lint.try_lint(names)
	end
end

return {
	{
		"mfussenegger/nvim-lint",
		event = lint_events,
		keys = {
			{
				"<leader>cl",
				try_lint,
				desc = "Lint 当前文件",
			},
		},
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = linters_by_ft

			vim.api.nvim_create_autocmd(lint_events, {
				group = vim.api.nvim_create_augroup("UserLint", { clear = true }),
				callback = try_lint,
			})

			vim.schedule(try_lint)
		end,
	},
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "诊断列表" },
			{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "当前文件诊断" },
			{ "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>", desc = "文档符号" },
			{ "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<CR>", desc = "LSP 定义/引用" },
			{ "<leader>xq", "<cmd>Trouble qflist toggle<CR>", desc = "Quickfix 列表" },
			{ "<leader>xL", "<cmd>Trouble loclist toggle<CR>", desc = "Location 列表" },
		},
		opts = {
			focus = true,
			auto_close = true,
			use_diagnostic_signs = true,
		},
	},
}
