return {
	{
		"stevearc/overseer.nvim",
		keys = {
			{ "<leader>or", "<cmd>OverseerRun<CR>", desc = "运行任务" },
			{ "<leader>oc", "<cmd>OverseerShell<CR>", desc = "运行命令任务" },
			{ "<leader>ot", "<cmd>OverseerToggle<CR>", desc = "切换任务列表" },
			{ "<leader>oa", "<cmd>OverseerTaskAction<CR>", desc = "任务操作" },
		},
		opts = {
			dap = false,
			templates = { "builtin", "my_go", "my_flutter", "my_docker" },
			task_list = {
				keymaps = {
					["<C-j>"] = false,
					["<C-k>"] = false,
				},
			},
			form = {
				zindex = 220,
				win_opts = {
					winblend = 0,
				},
			},
			task_win = {
				win_opts = {
					winblend = 0,
				},
			},
		},
	},
}
