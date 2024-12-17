---@type NvPluginSpec

return {
  "neovim/nvim-lspconfig",
  config = function()
    dofile(vim.g.base46_cache .. "lsp")

    local lspconfig = require "lspconfig"
    local lsp = require "gale.lsp"

    local servers = {
      astro = {},
      bashls = {
        on_attach = function(client, bufnr)
          local filename = vim.api.nvim_buf_get_name(bufnr)
          if filename:match "%.env$" then
            vim.lsp.stop_client(client.id)
          end
        end,
      },
      clangd = {},
      css_variables = {},
      cssls = {},
      eslint = {},
      html = {},
      hls = {},
      gopls = {},
      jsonls = {},
      lua_ls = {
        settings = {
          Lua = {
            hint = { enable = true },
            telemetry = { enable = false },
            diagnostics = { globals = { "bit", "vim", "it", "describe", "before_each", "after_each" } },
            -- workspace libraries are set via lazydev
          },
        },
      },
      marksman = {},
      ocamllsp = {},
      pyright = {},
      ts_ls = {},
      ruff = {
        on_attach = function(client, _)
          -- prefer pyright's hover provider
          client.server_capabilities.hoverProvider = false
        end,
      },
      somesass_ls = {},
      -- tailwindcss = {},
      taplo = {},
      vtsls = {
        settings = {
          javascript = {
            inlayHints = lsp.inlay_hints_settings,
            updateImportsOnFileMove = "always",
          },
          typescript = {
            inlayHints = lsp.inlay_hints_settings,
            updateImportsOnFileMove = "always",
          },
          vtsls = {
            tsserver = {
              globalPlugins = {
                "@styled/typescript-styled-plugin",
              },
            },
            experimental = {
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
          },
        },
      },
      --[[ rust_analyzer = {
        cmd = { 'rust-analyzer' },
        -- cmd = { 'rust-analyzer' },
        filetypes = { "rust" },
        diagnostics = {
          enable = true,
        },
        single_file_support = true,
      }, ]]
      yamlls = {},
      zls = {},
    }

    for name, opts in pairs(servers) do
      opts.on_init = lsp.on_init
      opts.on_attach = lsp.create_on_attach(opts.on_attach)

      opts.capabilities = lsp.capabilities
      --[[ if name ~= "rust_analyzer" then
        opts.capabilities = lsp.capabilities
      else
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
        opts.capabilities = capabilities
      end ]]
      lspconfig[name].setup(opts)
    end

    -- LSP UI
    local border = "rounded"
    local x = vim.diagnostic.severity
    vim.diagnostic.config {
      virtual_text = false,
      signs = { text = { [x.ERROR] = "", [x.WARN] = "", [x.INFO] = "", [x.HINT] = "󰌵" } },
      float = { border = border },
      underline = true,
    }

    -- Gutter
    vim.fn.sign_define("CodeActionSign", { text = "󰉁", texthl = "CodeActionSignHl" })
    local rust_config = function()
      local mason_registry = require "mason-registry"

      local codelldb = mason_registry.get_package "codelldb"
      local extension_path = codelldb:get_install_path() .. "/extension"
      local codelldb_path = extension_path .. "/adapter/codelldb"
      local liblldb_path = extension_path .. "/lldb/lib/liblldb.dylib"
      local this_os = vim.uv.os_uname().sysname

      -- The path is different on Windows
      if this_os:find "Windows" then
        codelldb_path = extension_path .. "adapter\\codelldb.exe"
        liblldb_path = extension_path .. "lldb\\bin\\liblldb.dll"
      else
        -- The liblldb extension is .so for Linux and .dylib for MacOS
        liblldb_path = liblldb_path .. (this_os == "Linux" and ".so" or ".dylib")
      end
      -- local cfg = require "rustaceanvim.config"

      -- local gale_lsp = require "gale.lsp"

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      vim.g.rustaceanvim = {
        tools = {
          runnables = {},
          debuggables = {},
          hover_actions = {
            auto_focus = true,
            border = "single",
          },
        },
        dap = {
          --adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
          --adapter = {
          --type = 'executable',
          --command = 'lldb-vscode',
          --name = "rt_lldb"
          --}
        },
        server = {
          --cmd = {"/home/sharks/source/dotfiles/misc/misc/rust-analyzer-wrapper"},
          --cmd = { "rustup", "run", "stable", "rust-analyzer" },
          -- cmd = { "/home/ethompson/.cargo/bin/rust-analyzer" },
          cmd = { "rust-analyzer" },
          on_attach = function(client, bufnr)
            local protocol = require "vim.lsp.protocol"

            local navic = require "nvim-navic"

            local caps = client.server_capabilities
            protocol.CompletionItemKind = {
              " ", -- text
              " ", -- method
              " ", -- function
              " ", -- ctor
              " ", -- field
              " ", -- variable
              " ", -- class
              " ", -- interface
              " ", -- module
              " ", -- property
              " ", -- unit
              " ", -- value
              " ", -- keyword
              " ", -- snippet
              " ", -- color
              " ", -- file
              " ", -- reference
              " ", -- folder
              " ", -- enum member
              " ", -- constant
              " ", -- struct
              " ", -- event
              " ", -- type parameter
            }

            if client.server_capabilities.documentSymbolProvider then
              navic.attach(client, bufnr)
            end

            -- if client.config.flags then
            --   client.config.flags.allow_incremental_sync = true
            -- end

            if caps.document_highlight then
              vim.api.nvim_exec(
                [[
    augroup lsp_document_highlight
      autocmd! * <buffer>
      autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()
      autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
      autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
    augroup END
    ]],
                false
              )
            end

            client.server_capabilities.semanticTokensProvider = nil
            -- if caps.semanticTokensProvider and caps.semanticTokensProvider.full then
            --   local augroup = vim.api.nvim_create_augroup("SemanticTokens", {})
            --   vim.cmd([[
            --     hi link LspComment TSComment
            --   ]])
            --   vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
            --     group = augroup,
            --     buffer = bufnr,
            --     callback = function()
            --       -- vim.lsp.buf.semantic_tokens_full()
            --       -- require('vim.lsp.semantic_tokens').refresh(bufnr)
            --     end,
            --   })
            --   -- fire it first time on load as well
            --   -- vim.lsp.buf.semantic_tokens_full()
            --   -- vim.lsp.semantic_tokens.refresh(bufnr)
            --   -- require('vim.lsp.semantic_tokens').refresh(bufnr)
            -- end

            -- format on save?
            --vim.cmd [[
            --augroup lsp_buf_format
            --au! BufWritePre <buffer>
            --autocmd BufWritePre <buffer> :lua vim.lsp.buf.formatting_sync()
            --augroup END
            --]]

            -- this breaks git-gutter?
            --lsp_status.on_attach(client)

            -- sharks_lsp.init()
          end,
          root_dir = require("plugins.spec.util").root_pattern "Cargo.toml",
          capabilities = capabilities,
          settings = {
            -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
            ["rust-analyzer"] = {
              updates = { channel = "stable" },
              imports = {
                granularity = {
                  enforce = false,
                  group = "crate",
                },
              },

              callinfo = {
                full = true,
              },

              cargo = {
                allfeatures = true,
                autoreload = true,
                loadoutdirsfromcheck = true,
              },

              -- checkonsave = {
              --   command = "clippy",
              --   allfeatures = true,
              --   extraargs = { "--tests" },
              -- },

              completion = {
                addcallargumentsnippets = true,
                addcallparenthesis = true,
                postfix = {
                  enable = true,
                },
                autoimport = {
                  enable = true,
                },
              },

              diagnostics = {
                enable = true,
                -- enableexperimental = true,
                disabled = {
                  "unresolved-proc-macro",
                  "unresolved-macro-call",
                },
              },

              hoveractions = {
                enable = true,
                debug = true,
                gototypedef = true,
                implementations = true,
                run = true,
                linksinhover = true,
              },

              inlayhints = {
                chaininghints = true,
                parameterhints = false,
                typehints = true,
              },

              lens = {
                enable = true,
                debug = true,
                implementations = true,
                run = true,
                methodreferences = true,
                references = true,
              },

              notifications = {
                cargotomlnotfound = true,
              },

              procmacro = {
                enable = true,
              },
            }, -- ["rust-analyzer"]
          }, -- settings
        }, -- lsp server
      }
      --[[ vim.g.rustaceanvim = {
      -- Dap configuration
      dap = {
        adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
      },
      -- Plugin configuration
      tools = {
        float_win_config = {
          border = "rounded",
        },
      },
      -- LSP configuration
      server = {
        capabilities = capabilities,
        -- capabilities = require("nvchad.configs.lspconfig").capabilities,
        cmd = function()
          if mason_registry.is_installed "rust-analyzer" then
            -- This may need to be tweaked depending on the operating system.
            local ra = mason_registry.get_package "rust-analyzer"
            local ra_filename = ra:get_receipt():get().links.bin["rust-analyzer"]
            return { ("%s/%s"):format(ra:get_install_path(), ra_filename or "rust-analyzer") }
          else
            -- global installation
            return { "rust-analyzer" }
          end
        end,
        on_attach = function(client, bufnr)
          local format_sync_grp = vim.api.nvim_create_augroup("RustaceanFormat", {})
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format()
            end,
            group = format_sync_grp,
          })

          local lsp_map = function(mode, keys, func, desc)
            vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = desc })
          end
          lsp_map("n", "K", function()
            vim.cmd.RustLsp { "hover", "actions" }
          end, "Rust hover docs")
          -- rust-lsp
          lsp_map("n", "<Leader>ca", function()
            vim.cmd.RustLsp "codeAction"
          end, "Rust Code action")
          lsp_map("n", "<Leader>rue", function()
            vim.cmd.RustLsp "explainError"
          end, "Rust error explain")
          lsp_map("n", "<Leader>rud", function()
            vim.cmd.RustLsp "openDocs"
          end, "Rust docs")
          lsp_map("n", "<Leader>rum", function()
            vim.cmd.RustLsp "expandMacro"
          end, "Rust expand macro")

          -- copy from lsp_config
          lsp_map("n", "gd", vim.lsp.buf.definition, "Goto definition")
          lsp_map("n", "gD", vim.lsp.buf.declaration, "Goto declaration")
          lsp_map("n", "gI", vim.lsp.buf.implementation, "Goto implementation")
          lsp_map("n", "go", vim.lsp.buf.type_definition, "Goto type definition")

          lsp_map("n", "gd", vim.lsp.buf.definition, "LSP go to definition")
          lsp_map("n", "gi", vim.lsp.buf.implementation, "LSP go to implementation")
          lsp_map("n", "<leader>gd", vim.lsp.buf.declaration, "LSP go to declaration")
          lsp_map("n", "<leader>sh", vim.lsp.buf.signature_help, "LSP show signature help")
          lsp_map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "LSP add workspace folder")
          lsp_map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "LSP remove workspace folder")
          lsp_map("n", "<leader>gr", vim.lsp.buf.references, "LSP show references")
          lsp_map("n", "<leader>gt", vim.lsp.buf.type_definition, "LSP go to type definition")

          lsp_map("n", "<leader>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, "LSP list workspace folders")

          lsp_map("n", "<leader>ra", function()
            require "nvchad.lsp.renamer"()
          end, "LSP rename")
        end,
        default_settings = {
          -- rust-analyzer language server configuration
          ["rust-analyzer"] = {
            -- Enable all features
            allFeatures = true,
            -- Load cargo out dirs from check
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
    } ]]
    end

    rust_config()
  end,
}
