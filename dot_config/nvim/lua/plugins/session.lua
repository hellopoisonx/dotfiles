return {
	{
		"rmagatti/auto-session",
		lazy = false,
		keys = {
			{ "<leader>sr", "<cmd>AutoSession restore<CR>", desc = "恢复当前目录 Session" },
			{ "<leader>ss", "<cmd>AutoSession save<CR>", desc = "保存当前目录 Session" },
			{ "<leader>sf", "<cmd>AutoSession search<CR>", desc = "查找 Session" },
			{ "<leader>sd", "<cmd>AutoSession delete<CR>", desc = "删除当前目录 Session" },
			{ "<leader>sD", "<cmd>AutoSession deletePicker<CR>", desc = "选择并删除 Session" },
			{ "<leader>st", "<cmd>AutoSession toggle<CR>", desc = "切换 Session 自动保存" },
			{ "<leader>sp", "<cmd>AutoSession purgeOrphaned<CR>", desc = "清理孤立 Session" },
		},
		opts = {
			suppressed_dirs = { "~/", "~/Downloads", "/" },
			close_unsupported_windows = true,
			auto_delete_empty_sessions = true,
			show_auto_restore_notif = false,
			lazy_support = true,
			bypass_save_filetypes = {
				"alpha",
				"dashboard",
				"gitcommit",
				"help",
				"lazy",
				"mason",
				"notify",
				"OverseerList",
				"qf",
				"Trouble",
			},
			session_lens = {
				picker = "telescope",
				load_on_setup = true,
				picker_opts = {
					border = true,
					layout_config = {
						width = 0.8,
						height = 0.5,
					},
				},
				mappings = {
					delete_session = { "i", "<C-d>" },
					alternate_session = { "i", "<C-s>" },
					copy_session = { "i", "<C-y>" },
				},
			},
		},
	},
}
