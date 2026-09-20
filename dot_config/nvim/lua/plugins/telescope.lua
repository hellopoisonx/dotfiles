return {
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		keys = {
			{ "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "全文搜索" },
			{ "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "查找文件" },
			{ "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "查找帮助" },
			{ "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "查找 Buffer" },
			{ "<leader>fs", "<cmd>Telescope grep_string<CR>", desc = "搜索光标词" },
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			defaults = {
				prompt_prefix = "   ",
				selection_caret = "❯ ",
				path_display = { "smart" },
				mappings = {
					i = {
						["<C-j>"] = "move_selection_next",
						["<C-k>"] = "move_selection_previous",
						["<C-q>"] = "send_selected_to_qflist",
					},
				},
			},
		},
	},
}
