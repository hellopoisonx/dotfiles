return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			bigfile = {
				enabled = true,
				notify = true,
				size = 1.5 * 1024 * 1024, -- 1.5MB
			},
			dim = {
				enabled = true,
			},
			quickfile = {
				enabled = true,
			},
			scope = {
				enabled = true,
			},
			rename = {
				enabled = true,
			},
			scroll = {
				enabled = true,
			},
			image = {
				enabled = true,
				doc = {
					enabled = true,
					inline = true,
				},
			},
			zen = {
				enabled = true,
				toggles = {
					dim = true,
				},
			},
		},
		keys = {
			{ "<leader>rn", function() Snacks.rename.rename_file() end, desc = "重命名文件 (LSP)" },
			{ "<leader>zh", function() Snacks.image.hover() end, desc = "图片悬浮预览" },
			{ "<leader>zz", function() Snacks.zen.zen() end, desc = "Zen 专注模式" },
			{ "<leader>zZ", function() Snacks.zen.zoom() end, desc = "Zoom 全屏" },
		},
		init = function()
			-- mini.files 重命名时通知 LSP
			vim.api.nvim_create_autocmd("User", {
				pattern = "MiniFilesActionRename",
				callback = function(event)
					Snacks.rename.on_rename_file(event.data.from, event.data.to)
				end,
			})
		end,
	},
}
