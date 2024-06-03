local dap = require("dap")

-- ui
require("configs.dap.ui")

-- debuggers
local lldb = require("configs.dap.adapters.lldb")

dap.adapters.lldb = lldb.adapter

dap.configurations.c = lldb.config
dap.configurations.cpp = lldb.config
dap.configurations.rust = lldb.config

require("dap-vscode-js").setup({
  opt = true,
  debugger_path = vim.fn.stdpath('data') .. "/lazy/vscode-js-debug",
  adapters = { 'chrome', 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost', 'node', 'chrome' }
})

require('dap.ext.vscode').load_launchjs(nil, {
  ['pwa-node'] = {'javascript', 'typescript'},
  ['node-terminal'] = { 'javascript', 'typescript' }
})

for _, language in ipairs({ "typescript", "javascript" }) do
  dap.configurations[language] = {
   {
    type = "pwa-node",
    request = "launch",
    name = "Launch file",
    program = "${file}",
    cwd = "${workspaceFolder}",
    sourceMaps = true,
    skipFiles = { "<node_internals>/**", "node_modules/**" },
  },
  {
    type = "pwa-node",
    request = "attach",
    name = "Attach",
    processId = require'dap.utils'.pick_process,
    cwd = "${workspaceFolder}",
  },
  {
    type = "node-terminal",
    request = "launch",
 }
}
end

