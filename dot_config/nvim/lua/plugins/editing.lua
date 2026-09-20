return {
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {
			check_ts = true,
			disable_filetype = { "TelescopePrompt", "Trouble", "OverseerForm" },
			fast_wrap = {},
		},
		config = function(_, opts)
			local npairs = require("nvim-autopairs")
			npairs.setup(opts)

			local ok_cmp, cmp = pcall(require, "cmp")
			local ok_cmp_autopairs, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
			if ok_cmp and ok_cmp_autopairs then
				cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
			end
		end,
	},
	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		opts = {},
	},
	{
		"jiaoshijie/undotree",
		keys = {
			{
				"<leader>u",
				function()
					require("undotree").toggle()
				end,
				desc = "切换 Undo Tree",
			},
		},
		opts = {},
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			indent = {
				char = "│",
				tab_char = "│",
			},
			scope = {
				enabled = true,
				show_start = true,
				show_end = false,
			},
			exclude = {
				filetypes = {
					"help",
					"lazy",
					"mason",
					"notify",
					"Trouble",
					"OverseerList",
				},
				buftypes = { "terminal", "nofile", "quickfix", "prompt" },
			},
		},
	},
}
