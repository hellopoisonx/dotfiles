return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	lazy = false,
	config = function()
		require("codecompanion").setup({
			adapters = {
				aliyun = function()
					return require("codecompanion.adapters").extend("openai_compatible", {
						env = {
							url = "https://dashscope.aliyuncs.com",
							api_key = "sk-298176e432cc4c90b02f38d69773afb0",
							chat_url = "/compatible-mode/v1/chat/completions",
						},
						schema = {
							model = {
								default = "deepseek-r1",
							},
						},
					})
				end,
				ty = function()
					return require("codecompanion.adapters").extend("openai_compatible", {
						env = {
							url = "https://dashscope.aliyuncs.com",
							api_key = "sk-298176e432cc4c90b02f38d69773afb0",
							chat_url = "/compatible-mode/v1/chat/completions",
						},
						schema = {
							model = {
								default = "qwen-omni-turbo",
							},
						},
					})
				end,
			},
			strategies = {
				chat = {
					adapter = "ty",
				},
				inline = {
					adapter = "ty",
					keymaps = {
						accept_change = {
							modes = { n = "ac" },
							description = "Accept the suggested change",
						},
						reject_change = {
							modes = { n = "rs" },
							description = "Reject the suggested change",
						},
					},
				},
			},
		})
	end,
}
