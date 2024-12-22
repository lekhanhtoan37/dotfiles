return {
  "stevearc/overseer.nvim",
  lazy = false,
  enabled = true,
  config = function()
    require("overseer").setup()
  end,
}
