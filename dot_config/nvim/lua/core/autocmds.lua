local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- 全局开关：默认开启，用 :AutoSaveToggle 或 vim.g.autosave_enabled 控制
vim.g.autosave_enabled = true

local function is_autosave_on()
	return vim.g.autosave_enabled == true
end

local function toggle_autosave()
	vim.g.autosave_enabled = not vim.g.autosave_enabled
	local status = vim.g.autosave_enabled and "开启" or "关闭"
	vim.notify("Auto-save: " .. status, vim.log.levels.INFO, { title = "Neovim" })
end

vim.api.nvim_create_user_command("AutoSaveToggle", toggle_autosave, {})
vim.api.nvim_create_user_command("AutoSaveOn", function() vim.g.autosave_enabled = true end, {})
vim.api.nvim_create_user_command("AutoSaveOff", function() vim.g.autosave_enabled = false end, {})
local autosave_delay = 1200

local autosave_group = augroup("AutoSaveAfterDelay", { clear = true })
local autosave_timers = {}

local function stop_timer(bufnr)
	local timer = autosave_timers[bufnr]
	if not timer then
		return
	end

	timer:stop()
	timer:close()
	autosave_timers[bufnr] = nil
end

local function should_autosave(bufnr)
	if not is_autosave_on() then
		return false
	end

	if not vim.api.nvim_buf_is_valid(bufnr) then
		return false
	end

	if not vim.bo[bufnr].modifiable or vim.bo[bufnr].readonly then
		return false
	end

	if vim.bo[bufnr].buftype ~= "" then
		return false
	end

	if vim.api.nvim_buf_get_name(bufnr) == "" then
		return false
	end

	if not vim.bo[bufnr].modified then
		return false
	end

	return true
end

local function save_buffer(bufnr)
	stop_timer(bufnr)

	if not should_autosave(bufnr) then
		return
	end

	vim.api.nvim_buf_call(bufnr, function()
		vim.cmd("silent update")
	end)
end

local function schedule_autosave(bufnr)
	if not should_autosave(bufnr) then
		stop_timer(bufnr)
		return
	end

	stop_timer(bufnr)

	local timer = vim.uv.new_timer()
	autosave_timers[bufnr] = timer
	timer:start(
		autosave_delay,
		0,
		vim.schedule_wrap(function()
			save_buffer(bufnr)
		end)
	)
end

local general = augroup("GeneralSettings", { clear = true })

autocmd("TextYankPost", {
	group = general,
	callback = function()
		vim.highlight.on_yank({ timeout = 150 })
	end,
})

autocmd({ "BufRead", "BufNewFile" }, {
	group = general,
	pattern = { "*.md", "*.txt", "*.tex" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
	end,
})

autocmd("FileType", {
	group = general,
	pattern = { "help", "man", "qf", "lspinfo", "checkhealth" },
	callback = function(event)
		vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
	end,
})

autocmd("LspAttach", {
	group = augroup("LspKeymaps", { clear = true }),
	callback = function(event)

		local map_buf = function(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { buffer = event.buf, silent = true, desc = desc })
		end

		local function telescope_or_builtin(picker, fallback, picker_opts)
			return function()
				local ok_telescope, telescope_builtin = pcall(require, "telescope.builtin")
				local telescope_picker = ok_telescope and telescope_builtin[picker]

				if type(telescope_picker) == "function" then
					local opts = vim.tbl_extend("force", { reuse_win = true }, picker_opts or {})
					local ok_picker = pcall(telescope_picker, opts)

					if ok_picker then
						return
					end
				end

				fallback()
			end
		end

		map_buf("K", vim.lsp.buf.hover, "悬浮文档")
		map_buf("gd", telescope_or_builtin("lsp_definitions", vim.lsp.buf.definition), "跳转定义")
		map_buf("gi", telescope_or_builtin("lsp_implementations", vim.lsp.buf.implementation), "跳转实现")
		if vim.bo[event.buf].filetype == "go" then
			map_buf("gI", telescope_or_builtin("lsp_implementations", vim.lsp.buf.implementation), "跳转接口实现")
		else
			map_buf("gI", telescope_or_builtin("lsp_type_definitions", vim.lsp.buf.type_definition), "跳转类型定义")
		end
		map_buf(
			"gr",
			telescope_or_builtin("lsp_references", vim.lsp.buf.references, { include_declaration = false }),
			"查找引用"
		)
		map_buf("<leader>cr", vim.lsp.buf.rename, "符号重命名")
		map_buf("<leader>ca", vim.lsp.buf.code_action, "代码操作")
	end,
})

autocmd({ "TextChanged", "TextChangedI" }, {
	group = autosave_group,
	callback = function(event)
		schedule_autosave(event.buf)
	end,
})

autocmd({ "InsertLeave", "BufLeave", "FocusLost", "VimLeavePre" }, {
	group = autosave_group,
	callback = function(event)
		save_buffer(event.buf)
	end,
})

autocmd({ "BufWritePost", "BufDelete", "BufWipeout" }, {
	group = autosave_group,
	callback = function(event)
		stop_timer(event.buf)
	end,
})
