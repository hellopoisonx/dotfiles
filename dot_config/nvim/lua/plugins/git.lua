return {
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "┃" },
				change = { text = "┃" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
			signs_staged_enable = true,
			signcolumn = true,
			numhl = false,
			linehl = false,
			word_diff = false,
			watch_gitdir = { follow_files = true },
			current_line_blame = false,
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol",
				delay = 600,
				ignore_whitespace = false,
			},
			preview_config = {
				border = "rounded",
				style = "minimal",
				relative = "cursor",
				row = 0,
				col = 1,
			},
			on_attach = function(bufnr)
				local gitsigns = require("gitsigns")

				local function map(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
				end

				map("n", "]g", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						gitsigns.nav_hunk("next")
					end
				end, "下一个 Git hunk")

				map("n", "[g", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						gitsigns.nav_hunk("prev")
					end
				end, "上一个 Git hunk")

				map("n", "<leader>gs", gitsigns.stage_hunk, "暂存 hunk")
				map("v", "<leader>gs", function()
					gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "暂存选中 hunk")
				map("n", "<leader>gr", gitsigns.reset_hunk, "重置 hunk")
				map("v", "<leader>gr", function()
					gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "重置选中 hunk")
				map("n", "<leader>gS", gitsigns.stage_buffer, "暂存当前文件")
				map("n", "<leader>gR", gitsigns.reset_buffer, "重置当前文件")
				map("n", "<leader>gu", gitsigns.undo_stage_hunk, "撤销暂存 hunk")
				map("n", "<leader>gp", gitsigns.preview_hunk, "预览 hunk")
				map("n", "<leader>gb", function()
					gitsigns.blame_line({ full = true })
				end, "查看当前行 blame")
				map("n", "<leader>gB", gitsigns.toggle_current_line_blame, "切换行尾 blame")
				map("n", "<leader>gd", gitsigns.diffthis, "查看当前文件 diff")
				map("n", "<leader>gD", function()
					gitsigns.diffthis("~")
				end, "查看当前文件与上一版本 diff")
				map({ "o", "x" }, "ih", gitsigns.select_hunk, "选择 Git hunk")
			end,
		},
	},
	{
		"kdheepak/lazygit.nvim",
		cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile" },
		keys = {
			{ "<leader>gg", "<cmd>LazyGit<CR>", desc = "打开 lazygit" },
		},
	},
}
