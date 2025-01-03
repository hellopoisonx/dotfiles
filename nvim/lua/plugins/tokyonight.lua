return {
  {
    "folke/tokyonight.nvim",
    enabled = true,
    lazy = false,
    priority = 1000,
    opts = { style = "storm" },
    config = function()
      require("tokyonight").setup({
        style = "storm",
        transparent = false,
      })
      vim.cmd([[colorscheme tokyonight-storm]])
    end,
  },
}
