return {
  "Pocco81/auto-save.nvim",
  enabled = true,
  lazy = true,
  event = "VimEnter",
  config = function()
    require("auto-save").setup({
      enabled = true,
      execution_message = {
        message = function() -- message to print on save
          return ""
        end,
        dim = 0.18, -- dim the color of `message`
        cleaning_interval = 1250, -- (milliseconds) automatically clean MsgArea after displaying `message`. See :h MsgArea
      },
      trigger_events = { "InsertLeave", "TextChanged" },
      write_all_buffers = false,
      debounce_delay = 6000,
    })
  end,
}
