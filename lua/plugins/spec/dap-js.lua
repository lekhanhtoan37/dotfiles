-- # DAP
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    {
      "rcarriga/nvim-dap-ui",
      dependencies = {
        "nvim-neotest/nvim-nio",
      },
    },
    "theHamsta/nvim-dap-virtual-text",
    "mxsdev/nvim-dap-vscode-js",
    {
      "microsoft/vscode-js-debug",
      lazy = false,
      build = function()
        local cwd = vim.fn.getcwd()
        local plugin_path = vim.fn.stdpath "data" .. "/lazy/" .. "vscode-js-debug"
        vim.fn.chdir(plugin_path)
        vim.fn.system {
          "npm",
          "install",
          "--legacy-peer-deps",
        }
        vim.fn.system {
          "npx",
          "gulp",
          "vsDebugServerBundle",
        }
        vim.fn.system {
          "mv",
          "dist",
          "out",
        }
        vim.fn.chdir(cwd)
      end,
    },
  },
  event = "VeryLazy",
  lazy = false,
  config = function()
    local dap = require "dap"
    local dap_utils = require "dap.utils"
    -- # DAP UI
    -- # Sign
    vim.fn.sign_define("DapBreakpoint", { text = "🟥", texthl = "", linehl = "", numhl = "" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "🟧", texthl = "", linehl = "", numhl = "" })
    vim.fn.sign_define("DapLogPoint", { text = "🟩", texthl = "", linehl = "", numhl = "" })
    vim.fn.sign_define("DapStopped", { text = "🈁", texthl = "", linehl = "", numhl = "" })
    vim.fn.sign_define("DapBreakpointRejected", { text = "⬜", texthl = "", linehl = "", numhl = "" })

    -- dap-vscode-js config
    local dap_vscode_js = require "dap-vscode-js"
    dap_vscode_js.setup {
      node_path = "node",
      debugger_path = vim.fn.stdpath "data" .. "/lazy/" .. "vscode-js-debug",
      adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost", "debugpy" },
      continue = function()
        if vim.fn.filereadable ".vscode/launch.json" then
          require("dap.ext.vscode").load_launchjs()
        end
        dap.continue()
      end,
    }

    local exts = {
      "go",
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
      -- using pwa-chrome
      "vue",
      "svelte",
    }

    for i, ext in ipairs(exts) do
      dap.configurations[ext] = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch Current File (pwa-node)",
          -- cwd = vim.fn.getcwd(),
          cwd = "${workspaceFolder}",
          args = { "${file}" },
          sourceMaps = true,
          protocol = "inspector",
        },
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch Current File (pwa-node with ts-node)",
          -- cwd = vim.fn.getcwd(),
          cwd = "${workspaceFolder}",
          runtimeArgs = { "--loader", "ts-node/esm" },
          runtimeExecutable = "node",
          args = { "${file}" },
          sourceMaps = true,
          runtimeArgs = {
            "--nolazy",
            "--inspect",
            "-r",
            "ts-node/register",
            "-r",
            "tsconfig-paths/register",
            "--unhandled-rejections=strict",
          },
          protocol = "inspector",
          skipFiles = { "<node_internals>/**", "node_modules/**" },
          resolveSourceMapLocations = {
            "${workspaceFolder}/**",
            "!**/node_modules/**",
          },
        },
      }
    end
  end,
}
