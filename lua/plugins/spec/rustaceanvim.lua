---@type NvPluginSpec
return {
  "mrcjkb/rustaceanvim",
  version = "^5",
  ft = { "rust" },
  config = function()
    vim.g.rustaceanvim = {
      -- Plugin configuration
      tools = {
        float_win_config = {
          border = "rounded",
        },
      },
      -- LSP configuration
      server = {
        capabilities = require("gale.lsp").capabilities,
        on_attach = function(client, bufnr)
          require("gale.lsp").create_on_attach(function(client, bufnr)
            local map = vim.keymap.set
            map(
              "n",
              "K",
              "<cmd>lua vim.cmd.RustLsp({ 'hover', 'actions' })<CR>",
              { buffer = bufnr, desc = "Rust Hover" }
            )
            map(
              "n",
              "<C-Space>",
              "<cmd>lua vim.cmd.RustLsp({ 'completion' })<CR>",
              { buffer = bufnr, desc = "Rust Completion" }
            )
            map(
              "n",
              "<leader>ca",
              "<cmd>lua vim.cmd.RustLsp('codeAction')<CR>",
              { buffer = bufnr, desc = "Rust Code actions" }
            )
          end)(client, bufnr)
        end,
        default_settings = {
          -- rust-analyzer language server configuration
          ["rust-analyzer"] = {},
        },
      },
      -- DAP configuration
      dap = {},
    }
  end,
}
