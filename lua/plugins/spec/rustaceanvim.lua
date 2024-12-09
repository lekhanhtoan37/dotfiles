---@type NvPluginSpec
return {
  "mrcjkb/rustaceanvim",
  lazy = false,
  version = "5.17.0",
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
        capabilities = require("nvchad.configs.lspconfig").capabilities,
        cmd = function()
          local mason_registry = require('mason-registry')
          if mason_registry.is_installed('rust-analyzer') then
            -- This may need to be tweaked depending on the operating system.
            local ra = mason_registry.get_package('rust-analyzer')
            local ra_filename = ra:get_receipt():get().links.bin['rust-analyzer']
            return { ('%s/%s'):format(ra:get_install_path(), ra_filename or 'rust-analyzer') }
          else
            -- global installation
            return { 'rust-analyzer' }
          end
        end,
        on_attach = function(_, bufnr)
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
        end,
        default_settings = {
          -- rust-analyzer language server configuration
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              buildScripts = {
                enable = true,
              },
            },
            -- Add clippy lints for Rust if using rust-analyzer
            checkOnSave = diagnostics == "rust-analyzer",
            -- Enable diagnostics if using rust-analyzer
            diagnostics = {
              enable = diagnostics == "rust-analyzer",
            },
            procMacro = {
              enable = true,
              ignored = {
                ["async-trait"] = { "async_trait" },
                ["napi-derive"] = { "napi" },
                ["async-recursion"] = { "async_recursion" },
              },
            },
          },
        },
      },
      -- DAP configuration
      dap = {},
    }
  end,
}
