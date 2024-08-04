---@type ChadrcConfig
local M = {}

-- Path to overriding theme and highlights files
local highlights = require("highlights")
local overrides = require("configs.overrides")

M.ui = {
	theme = "catppuccin",
	theme_toggle = { "onedark","catppuccin", "one_light", 'palenight', 'github_dark', 'vscode_dark' },

	hl_override = highlights.override,
	hl_add = highlights.add,
}

-- M.plugins = "plugins"

M.ui = overrides.ui

-- check core.mappings for table structure
M.mappings = require("mappings")

return M
