---@type NvPluginSpec
return {
  "mrcjkb/rustaceanvim",
  version = "^5",
  ft = { "rust" },
  on_attach = function(client, bufnr)
    require("dap.ext.vscode").load_launchjs()
    require("gale.lsp").create_on_attach(function(client, bufnr)
      local map = vim.keymap.set
      map("n", "K", "<cmd>lua vim.cmd.RustLsp({ 'hover', 'actions' })<CR>", { buffer = bufnr, desc = "Rust Hover" })
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
  config = function()
    local registry = require "mason-registry"
    -- Ensure rust-analyzer is installed
    if not registry.is_installed "rust-analyzer" then
      local rust_analyzer = registry.get_package "rust-analyzer"
      rust_analyzer:install()
    end
    if not registry.is_installed "codelldb" then
      local codelldb = registry.get_package "codelldb"
      codelldb:install()
    end

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
      dap = {
        autoload_configurations = true,
      },
    }
  end,
}
