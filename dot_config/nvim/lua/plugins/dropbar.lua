-- LSP / Treesitter 面包屑：在 winbar 区域显示当前函数 / 类 / 命名空间等上下文
-- 多 backend 自动 fallback：lsp -> treesitter -> path
-- 自带下拉菜单、pick mode、fuzzy finder（需 telescope-fzf-native）
-- 自带 winbar attach（plugin/dropbar.lua 启动时自动），所以本配置不需 options.lua 设置 winbar
return {
	{
		"Bekaboo/dropbar.nvim",
		event = "BufReadPre", -- 等第一次打开文件就 attach，否则首屏看不到
		dependencies = {
			"nvim-telescope/telescope-fzf-native.nvim", -- 可选：菜单内 fzf 模糊搜索
		},
		config = function()
			-- 启用 mousemove 事件，让菜单 / winbar 支持 hover 高亮
			vim.api.nvim_set_hl(0, "MsgArea", {})
			if vim.fn.exists("+mousemoveevent") == 1 then
				vim.o.mousemoveevent = true
			end

			local dropbar_api = require("dropbar.api")
			require("dropbar").setup({
				-- 调整 padding 让 winbar 文本两侧留点空隙
				bar = {
					padding = { left = 1, right = 1 },
				},
				-- 菜单预览：鼠标悬停时在原窗口预览符号位置
				menu = {
					preview = true,
				},
			})

			-- 实用键映射（中文 desc，会被 which-key 接管）
			vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "面包屑：选择符号" })
			vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "面包屑：跳到当前 context 起点" })
			vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "面包屑：选下一个 context" })
		end,
	},
}
