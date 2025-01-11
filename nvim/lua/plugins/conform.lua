return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			c = { "clang-format" },
			cpp = { "clang-format" },
			hpp = { "clang-format" },
			h = { "clang-format" },
			cmake = { "cmake_format" },
			lua = { "stylua" },
		},
	},
}
