---@type NvPluginSpec
return {
  "mfussenegger/nvim-dap-python",
  ft = "python",
  dependencies = {
    { "mfussenegger/nvim-dap" },
    { "rcarriga/nvim-dap-ui" },
  },
  lazy = false,
  config = function()
    local dap_py = require "dap-python"
    local default_path = "~/.pyenv/shims/python"
    local pythonPath = function()
      -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
      -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
      -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
      local cwd = vim.fn.getcwd()
      if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
        return cwd .. "/venv/bin/python"
      elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
        return cwd .. "/.venv/bin/python"
      else
        return default_path
      end
    end

    dap_py.setup(pythonPath())
    if vim.fn.filereadable ".vscode/launch.json" then
      require("dap.ext.vscode").load_launchjs()
    end
    vim.keymap.set("n", "<leader>pdr", function()
      dap_py.test_method()
    end, { desc = "Run Python debug" })
  end,
}
