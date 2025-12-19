return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown", "codecompanion" },
	},
	{
		"olimorris/codecompanion.nvim",
		version = "17.33.0",
		pin = true,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			-- NOTE: The log_level is in `opts.opts`
			ignore_warnings = true,
			opts = {
				language = "Chinese",
				log_level = "DEBUG", -- or "TRACE"
			},
			adapters = {
				http = {
					deepseek_v3_2 = function()
						return require("codecompanion.adapters").extend("openai", {
							url = "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions",
							env = {
								api_key = "{YOUR_KEY}",
							},
							schema = {
								model = {
									default = "deepseek-v3",
								},
							},
						}) end,
				},
			},
			strategies = {
				chat = {
					adapter = "deepseek_v3_2",
				},
				inline = {
					adapter = "deepseek_v3_2",
				},
			},
		},
	},
}
