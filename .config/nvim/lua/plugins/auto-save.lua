return {
	"Pocco81/auto-save.nvim",
	lazy = true,
	event = "VeryLazy",
	opts = {
		debounce_delay = 1000,
		execution_message = {
			message = function() -- message to print on save
				return ""
			end,
			dim = 0.18, -- dim the color of `message`
			cleaning_interval = 1250, -- (milliseconds) automatically clean MsgArea after displaying `message`. See :h MsgArea
		},
	},
}
