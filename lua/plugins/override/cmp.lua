---@type NvPluginSpec
return {
  "hrsh7th/nvim-cmp",
  enabled = true,
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    { "hrsh7th/cmp-cmdline" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "brenoprata10/nvim-highlight-colors" },
    { "hrsh7th/cmp-nvim-lua" },
    { "hrsh7th/cmp-nvim-lsp-signature-help" },
    { "hrsh7th/cmp-vsnip" },
    { "hrsh7th/cmp-path" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/vim-vsnip" },
    {
      "zjp-CN/nvim-cmp-lsp-rs",
      ---@type cmp_lsp_rs.Opts
      opts = {
        -- Filter out import items starting with one of these prefixes.
        -- A prefix can be crate name, module name or anything an import
        -- path starts with, no matter it's complete or incomplete.
        -- Only literals are recognized: no regex matching.
        unwanted_prefix = { "color", "ratatui::style::Styled" },
        -- make these kinds prior to others
        -- e.g. make Module kind first, and then Function second,
        --      the rest ordering is merged from a default kind list
        kind = function(k)
          -- The argument in callback is type-aware with opts annotated,
          -- so you can type the CompletionKind easily.
          return { k.Module, k.Function }
        end,
        -- Override the default comparator list provided by this plugin.
        -- Mainly used with key binding to switch between these Comparators.
        combo = {
          -- The key is the name for combination of comparators and used
          -- in notification in swiching.
          -- The value is a list of comparators functions or a function
          -- to generate the list.
          alphabetic_label_but_underscore_last = function()
            local comparators = require("cmp_lsp_rs").comparators
            return { comparators.sort_by_label_but_underscore_last }
          end,
          recentlyUsed_sortText = function()
            local compare = require("cmp").config.compare
            local comparators = require("cmp_lsp_rs").comparators
            -- Mix cmp sorting function with cmp_lsp_rs.
            return {
              compare.recently_used,
              compare.sort_text,
              comparators.sort_by_label_but_underscore_last,
            }
          end,
        },
      },
    },
  },
  config = function(_, opts)
    local cmp = require "cmp"

    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })

    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "cmdline" },
        { name = "path" },
        {
          name = "lazydev",
          group_index = 0, -- set group index to 0 to skip loading LuaLS completions
        },
      },
    })
    -- cmp.setup.sources

    local colors = require "nvim-highlight-colors.color.utils"
    local utils = require "nvim-highlight-colors.utils"

    ---@class cmp.FormattingConfig
    --- This makes chadrc.ui.cmp take no effect
    opts.formatting = {
      fields = { "abbr", "kind", "menu" },

      format = function(entry, item)
        local icons = require "nvchad.icons.lspkind"
        icons.Color = "󱓻"

        local icon = " " .. icons[item.kind] .. " "
        item.kind = string.format("%s%s ", icon, item.kind)

        local entryItem = entry:get_completion_item()
        if entryItem == nil then
          return item
        end

        local entryDoc = entryItem.documentation
        if entryDoc == nil or type(entryDoc) ~= "string" then
          return item
        end

        local color_hex = colors.get_color_value(entryDoc)
        if color_hex == nil then
          return item
        end

        local highlight_group = utils.create_highlight_name("fg-" .. color_hex)
        vim.api.nvim_set_hl(0, highlight_group, { fg = color_hex, default = true })
        item.kind_hl_group = highlight_group

        return item
      end,
    }

    local cmp_lsp_rs = require "cmp_lsp_rs"
    local comparators = cmp_lsp_rs.comparators
    local compare = require("cmp").config.compare

    ---@type cmp.ConfigSchema
    local custom_opts = {
      sorting = {
        priority_weight = 1,
        comparators = {
          compare.exact,
          compare.score,
          comparators.inherent_import_inscope,
          comparators.inscope_inherent_import,
          comparators.sort_by_label_but_underscore_last,
        },
      },
      mapping = {
        -- Add tab support
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<C-S-f>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping.confirm { select = false },
      },
      window = {
        completion = {
          border = "rounded",
        },
        documentation = {
          border = "rounded",
        },
      },
      sources = {
        { name = "nvim_lsp" }, -- from language server
        { name = "path" }, -- file paths
        { name = "nvim_lsp_signature_help" }, -- display function signatures with current parameter emphasized
        { name = "nvim_lua" }, -- complete neovim's Lua runtime API such vim.lsp.*
        { name = "buffer" }, -- source current buffer
        { name = "vsnip", keyword_length = 2 }, -- nvim-cmp source for vim-vsnip
        { name = "calc" },
        { name = "luasnip" },
        { name = "supermaven" },
      },
      snippet = {
        expand = function(args)
          -- vim.fn["vsnip#anonymous"](args.body) -- For 'vsnip' users.
          require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
        end,
      },
    }

    opts = vim.tbl_deep_extend("force", opts, custom_opts)
    for _, source in ipairs(opts.sources) do
      cmp_lsp_rs.filter_out.entry_filter(source)
    end
    cmp.setup(opts)
  end,
}
