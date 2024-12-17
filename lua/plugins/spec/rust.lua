---@type NvPluginSpec
return {
  "simrat39/rust-tools.nvim",
  lazy = true,
  enabled = false,
  event = "BufReadPost",
  ft = { "rust" },
  opts = {
    setup = {
      rust_analyzer = function(_, opts)
        require("lazyvim.util").on_attach(function(client, buffer)
          -- stylua: ignore
          if client.name == "rust_analyzer" then
            vim.keymap.set("n", "K", "<cmd>RustHoverActions<cr>", { buffer = buffer, desc = "Hover Actions (Rust)" })
            vim.keymap.set("n", "<leader>cR", "<cmd>RustCodeAction<cr>", { buffer = buffer, desc = "Code Action (Rust)" })
            vim.keymap.set("n", "<leader>dr", "<cmd>RustDebuggables<cr>",
              { buffer = buffer, desc = "Run Debuggables (Rust)" })
          end
        end)
        local mason_registry = require("mason-registry")
        -- rust tools configuration for debugging support
        local codelldb = mason_registry.get_package("codelldb")
        local extension_path = codelldb:get_install_path() .. "/extension/"
        local codelldb_path = extension_path .. "adapter/codelldb"
        local liblldb_path = vim.fn.has("mac") == 1 and extension_path .. "lldb/lib/liblldb.dylib"
            or extension_path .. "lldb/lib/liblldb.so"
        for _, method in ipairs({ "textDocument/diagnostic", "workspace/diagnostic" }) do
          local default_diagnostic_handler = vim.lsp.handlers[method]
          vim.lsp.handlers[method] = function(err, result, context, config)
            if err ~= nil and err.code == -32802 then
              return
            end
            return default_diagnostic_handler(err, result, context, config)
          end
        end

        local rust_tools_opts = vim.tbl_deep_extend("force", opts, {
          dap = {
            adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
          },
          tools = {
            -- on_initialized = function()
            -- vim.cmd([[
            -- augroup RustLSP
            -- autocmd CursorHold                      *.rs silent! lua vim.lsp.buf.document_highlight()
            -- autocmd CursorMoved,InsertEnter         *.rs silent! lua vim.lsp.buf.clear_references()
            -- autocmd BufEnter,CursorHold,InsertLeave *.rs silent! lua vim.lsp.codelens.refresh()
            -- augroup END
            -- ]])
            -- end,
          },
          server = {
            capabilities = require("gale.lsp").capabilities,
            cmd = { "rust-analyzer" },
            handlers = {
              ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" }),
              ["textDocument/signatureHelp"] = vim.lsp.with(
                vim.lsp.handlers.signature_help,
                { border = "single" }
              ),
            },
            on_attach = function(client, buf)
              client.server_capabilities.completionProvider = true
            end,
            settings = {
              ["rust-analyzer"] = {
                cmd = { 'rust-analyzer' },
                root_dir = require("plugins.spec.util").root_pattern("Cargo.toml", "rust-project.json"),
                cargo = {
                  allFeatures = true,
                  loadOutDirsFromCheck = true,
                  runBuildScripts = true,
                },
                -- Add clippy lints for Rust.
                checkOnSave = {
                  allFeatures = true,
                  command = "clippy",
                  extraArgs = { "--no-deps" },
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
        })
        require("rust-tools").setup(rust_tools_opts)
        return true
      end,
    },
  },
}
