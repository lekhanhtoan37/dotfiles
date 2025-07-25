---@type NvPluginSpec
return {
  "OXY2DEV/markview.nvim",
  lazy = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  opts = function(_, opts)
    dofile(vim.g.base46_cache .. "markview")
    local presets = require "markview.presets"

    ---@type markview.configuration
    ---@diagnostic disable-next-line
    local new_opts = {
      highlight_groups = "dynamic",
      ---@diagnostic disable-next-line
      preview = {
        modes = { "i", "n", "v", "vs", "V", "Vs", "no", "c" },
        hybrid_modes = { "i" },
        callbacks = {
          on_enable = function(_, win)
            -- https://github.com/OXY2DEV/markview.nvim/issues/75
            vim.wo[win].wrap = false

            -- https://segmentfault.com/q/1010000000532491
            vim.wo[win].conceallevel = 2
            vim.wo[win].concealcursor = "nivc"
          end,
        },
      },
      markdown = {
        headings = presets.headings.arrowed,
        tables = {
          use_virt_lines = true,
        },
      },
      markdown_inline = {
        entities = {
          enable = true,
          hl = nil,
        },
      },
      checkboxes = presets.checkboxes.nerd,
      ---@diagnostic disable-next-line
      html = {
        enable = true,
        ---@diagnostic disable-next-line
        tags = {
          enable = true,
          default = {
            conceal = true,
            ---@type string?
            hl = nil,
          },
        },
      },
    }

    opts = vim.tbl_deep_extend("force", new_opts, opts or {})
    return opts
  end,
}
