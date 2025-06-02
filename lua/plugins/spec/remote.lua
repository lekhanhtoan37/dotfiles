---@type NvPluginSpec
return {
   "amitds1997/remote-nvim.nvim",
   version = "*", -- Pin to GitHub releases
   lazy = false,
   dependencies = {
       "nvim-lua/plenary.nvim", -- For standard functions
       "MunifTanjim/nui.nvim", -- To build the plugin UI
       "nvim-telescope/telescope.nvim", -- For picking b/w different remote methods
   },
   config = true,
   init = function()
       require("remote-nvim").setup()
   end,
}
