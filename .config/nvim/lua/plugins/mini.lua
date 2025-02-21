return {
	{
		"echasnovski/mini.files",
		lazy = true,
		version = "*",
		opts = {
			windows = {
				preview = true,
			},
			options = {
				use_as_default_explorer = true,
			},
		},
	},
	{
		"echasnovski/mini.icons",
		version = "*",
		lazy = false,
		opts = {
			style = "glyph",
		},
	},
	{
		"echasnovski/mini.comment",
		version = "*",
		lazy = true,
		opts = {
			mappings = {
				comment = "gc",
				comment_line = "gcc",
				comment_visual = "gc",
				textobject = "gc",
			},
		},
	},
	{
		"echasnovski/mini.statusline",
		version = "*",
		lazy = true,
		event = "VimEnter",
		opts = {},
	},
	{
		"echasnovski/mini.indentscope",
		version = "*",
		lazy = true,
		event = "VimEnter",
		opts = {},
	},
	{
		"echasnovski/mini.tabline",
		version = "*",
		lazy = true,
		event = "VimEnter",
		opts = {},
	},
	{
		"echasnovski/mini.pick",
		version = "*",
		lazy = true,
		event = "VeryLazy",
		opts = {},
	},
	{
		"echasnovski/mini.extra",
		version = "*",
		opts = {},
	},
	{
		"echasnovski/mini.pairs",
		version = "*",
		lazy = true,
		event = "InsertEnter",
		opts = {},
	},
}
