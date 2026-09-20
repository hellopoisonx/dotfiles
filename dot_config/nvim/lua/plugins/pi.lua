return {
	{
		"pablopunk/pi.nvim",
		cmd = { "PiAsk", "PiAskSelection", "PiCancel", "PiLog" },
		keys = {
			{ "<leader>ai", mode = { "n" }, ":PiAsk<CR>", desc = "Pi: 提问 (当前 Buffer)" },
			{ "<leader>ai", mode = { "v" }, ":PiAskSelection<CR>", desc = "Pi: 提问 (选区)" },
			{ "<leader>ac", ":PiCancel<CR>", desc = "Pi: 取消当前请求" },
			{ "<leader>al", ":PiLog<CR>", desc = "Pi: 查看会话日志" },
		},
		opts = {
			provider = "deepseek",
			model = "deepseek-v4-flash",
			thinking = "off",
			context = {
				max_bytes = 48000,
				diagnostics = {
					enabled = true,
				},
			},
		},
	},
}
