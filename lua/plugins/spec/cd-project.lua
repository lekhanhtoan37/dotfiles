---@type NvPluginSpec
return {
  "LintaoAmons/cd-project.nvim",
  tag = "v0.11.0",
  dev = false,
  event = "VimEnter",
  opts = {
    projects_config_filepath = vim.fn.expand "~/.cd-project.nvim.json",
    project_dir_pattern = { ".git", ".gitignore", "Cargo.toml", "package.json", "go.mod" },
    projects_picker = "telescope", -- "vim-ui" | "telescope"
    hooks = {
      {
        callback = function(dir)
          vim.notify("Switched to dir: " .. dir)
        end,
      },
      {
        callback = function(dir)
          vim.notify("Switched to dir: " .. dir)
        end,
        name = "cd hint",
        order = 1,
        pattern = "cd-project.nvim",
        trigger_point = "DISABLE",
        match_rule = function(dir)
          return true
        end,
      },
    },
  },
}
