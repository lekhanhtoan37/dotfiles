local overrides = require("configs.overrides")
-- Function to run shell commands sequentially
-- Function to run shell commands sequentially
local function run_commands(commands, on_failure, on_success)
	local index = 1

	local function run_next()
		if index > #commands then
			if on_success then
				on_success()
			end
			return
		end

		local cmd = commands[index]
		if cmd then
			-- Construct the command string from the array elements
			local cmd_string = cmd[1] .. " " .. table.concat(cmd[2], " ")
			print("Running command: " .. cmd_string)
			local result = vim.fn.system(cmd_string)
			local exit_code = vim.v.shell_error

			if exit_code ~= 0 then
				print("Command failed: " .. cmd_string)
				print("Error: " .. result)
				if on_failure then
					on_failure()
				end
				return
			else
				print("Command succeeded: " .. cmd_string)
				print("Output: " .. result)
			end
		else
			print("Error: Command is nil.")
			if on_failure then
				on_failure()
			end
			return
		end

		index = index + 1
		run_next()
	end

	run_next()
end

-- Function to remove the plugin directory
local function remove_plugin_dir(plugin_name)
	local plugin_path = vim.fn.stdpath("data") .. "/lazy/" .. plugin_name
	if vim.fn.delete(plugin_path, "rf") == 0 then
		print("Successfully removed plugin directory: " .. plugin_path)
	else
		print("Failed to remove plugin directory: " .. plugin_path)
	end
end

return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			-- format & linting
			{
				"jose-elias-alvarez/null-ls.nvim",
				config = function()
					require("configs.lsp.null-ls")
				end,
			},
            {
              "lvimuser/lsp-inlayhints.nvim",
              config = function()
                require("lsp-inlayhints").setup()
                vim.api.nvim_create_augroup("LspAttach_inlayhints", {})
                vim.api.nvim_create_autocmd("LspAttach", {
                  group = "LspAttach_inlayhints",
                  callback = function(args)
                    if not (args.data and args.data.client_id) then
                      return
                    end

                    local bufnr = args.buf
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    require("lsp-inlayhints").on_attach(client, bufnr, false)
                  end,
                })
              end,
            },
            {"williamboman/mason-lspconfig.nvim"}
		},
		config = function()
			require("nvchad.configs.lspconfig").defaults() -- nvchad defaults for lua
			require("configs.lsp")
            -- require("nvchad.configs.lspconfig.gopls").setup({
            --     ["ui.inlayhint.hints"] = {
            --         parameterNames = true,
            --         typeHints = true,
            --         otherHints = true,
            --     }
            -- })
		end, -- Override to setup mason-lspconfig
	},

	{
		"williamboman/mason.nvim",
		opts = overrides.mason,
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup()
            -- require("lsqconfig").gopls.setup({
            --     ["ui.inlayhint.hints"] = {
            --         parameterNames = true,
            --         typeHints = true,
            --         otherHints = true,
            --     }
            -- })
        end,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		opts = overrides.treesitter,
	},

	{
		"nvim-tree/nvim-tree.lua",
        dependencies = {
            "kyazdani42/nvim-web-devicons",
        },
		opts = overrides.nvimtree,
	},

	{
		"nvim-telescope/telescope.nvim",
		opts = overrides.telescope,
	},

	{
		"telescope.nvim",
		dependencies = {
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			lazy = false,
			config = function()
				require("telescope").load_extension("fzf")
			end,
		},
	},

	{
		"lewis6991/gitsigns.nvim",
		opts = overrides.gitsigns,
	},

	{
		"hrsh7th/nvim-cmp",
		opts = overrides.cmp,
	},

	-- Additional plugins

	-- escape using key combo (currently set to jk)
	{
		"max397574/better-escape.nvim",
		event = "InsertEnter",
		config = function()
			require("configs.betterescape")
		end,
	},
	-- {
	-- 	"mfussenegger/nvim-dap",
	-- 	dependencies = {
	-- 		{
	-- 			"nvim-dap-virtual-text",
	-- 			config = function()
	-- 				require("nvim-dap-virtual-text").setup()
	-- 			end,
	-- 		},
	-- 	},
  -- },
	-- {
	-- 	"rcarriga/nvim-dap-ui",
	-- 	dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
	-- 	-- config = function()

	-- 	-- end
	-- },
	{
		"microsoft/vscode-js-debug",
		lazy = true,
		build = function()
      local cwd = vim.fn.getcwd()
			local plugin_path = vim.fn.stdpath("data") .. "/lazy/" .. "vscode-js-debug"
			vim.fn.chdir(plugin_path)
			vim.fn.system({
				"npm",
				"install",
				"--legacy-peer-deps",
			})
			vim.fn.system({
				"npx",
				"gulp",
				"vsDebugServerBundle",
			})
			vim.fn.system({
				"mv",
				"dist",
				"out",
			})
      vim.fn.chdir(cwd)
		end,
	},
	-- {
	-- 	"mxsdev/nvim-dap-vscode-js",
  --   dependencies = {
	-- 		"mfussenegger/nvim-dap",
	-- 		"microsoft/vscode-js-debug",
	-- 		"rcarriga/nvim-dap-ui",
	-- 		"nvim-dap-virtual-text",
  --   },
	-- 	config = function()
	-- 		local dap, dapui = require("dap"), require("dapui")

	-- 		-- open / close ui windows automatically
	-- 		dap.listeners.after.event_initialized["dapui_config"] = function()
	-- 			dapui.open()
	-- 		end
	-- 		dap.listeners.before.event_terminated["dapui_config"] = function()
	-- 			dapui.close()
	-- 		end
	-- 		dap.listeners.before.event_exited["dapui_config"] = function()
	-- 			dapui.close()
	-- 		end

	-- 		vim.keymap.set('n', '<Leader>ui', require 'dapui'.toggle)

	-- 		require('dap.ext.vscode').load_launchjs(nil, {
	-- 			['pwa-node'] = {'javascript', 'typescript'},
	-- 			['node-terminal'] = { 'javascript', 'typescript' }
	-- 		})

	-- 		require("dap-vscode-js").setup({
	-- 			debugger_path = vim.fn.stdpath("data") .. "/lazy/" .. "vscode-js-debug",
	-- 			adapters = {
	-- 				"chrome",
	-- 				"pwa-node",
	-- 				"pwa-chrome",
	-- 				"pwa-msedge",
	-- 				"node-terminal",
	-- 				"pwa-extensionHost",
	-- 				"node",
	-- 				"chrome",
	-- 			},
	-- 		})

	-- 		local js_based_languages = { "typescript", "javascript", "typescriptreact" }

	-- 		for _, language in ipairs(js_based_languages) do
	-- 			dap.configurations[language] = {
	-- 				{
	-- 					type = "pwa-node",
	-- 					request = "launch",
	-- 					name = "Launch file",
	-- 					program = "${file}",
	-- 					cwd = "${workspaceFolder}",
	-- 				},
	-- 				{
	-- 					type = "pwa-node",
	-- 					request = "attach",
	-- 					name = "Attach",
	-- 					processId = require("dap.utils").pick_process,
	-- 					cwd = "${workspaceFolder}",
	-- 				},
	-- 				{
	-- 					type = "pwa-chrome",
	-- 					request = "launch",
	-- 					name = 'Start Chrome with "localhost"',
	-- 					url = "http://localhost:3000",
	-- 					webRoot = "${workspaceFolder}",
	-- 					userDataDir = "${workspaceFolder}/.vscode/vscode-chrome-debug-userdatadir",
	-- 				},
	-- 				{
	-- 					name = "Npm",
	-- 					type = "node-terminal",
	-- 					request = "launch",
	-- 					command = "npm run start",
	-- 				}
	-- 			}
	-- 		end

	-- 		local continue = function()
  --       if vim.fn.filereadable('.vscode/launch.json') then
  --         require('dap.ext.vscode').load_launchjs()
  --       end  
  --       dap.continue()
  --     end

  --     lvim.lsp.buffer_mappings.normal_mode["<leader>dc"] = { continue, "Start/Continue debug" }
	-- 	end,
	-- },
	-- {
	-- 	"theHamsta/nvim-dap-virtual-text",
	-- 	config = function()
	-- 		require("nvim-dap-virtual-text").setup()
	-- 	end,
	-- 	requires = { "nvim-dap" },
	-- },
	require("configs.dapp.main").plugin,
	{
		"ojroques/nvim-bufdel",
		lazy = false,
	},
	{
		"nvim-lua/plenary.nvim",
	},
	{
		"vimwiki/vimwiki",
	},
	{
		"zbirenbaum/copilot.lua",
		event = "InsertEnter",
		config = function()
			require("copilot").setup(require("configs.copilot"))
		end,
	},
	{
		"leoluz/nvim-dap-go",
		ft = "go",
		dependencies = "mfussenegger/nvim-dap",
		config = function(_, opts)
			require("dap-go").setup(opts)
		end,
	},
    {
        "mg979/vim-visual-multi",
        branch = "master",
        init = function()
            vim.g.VM_maps = {}
            vim.g.VM_maps["Find Under"] = ""
        end,
    },
    -- {
    --     "otavioschwanck/cool-substitute.nvim",
    --     config = function()
    --         require("cool-substitute").setup({
    --             mappings = {
    --                 start = 'gm', -- Mark word / region
    --                 start_and_edit = 'gM', -- Mark word / region and also edit
    --                 start_and_edit_word = 'g!M', -- Mark word / region and also edit.  Edit only full word.
    --                 start_word = 'g!m', -- Mark word / region. Edit only full word
    --                 apply_substitute_and_next = 'M', -- Start substitution / Go to next substitution
    --                 apply_substitute_and_prev = '<C-b>', -- same as M but backwards
    --                 apply_substitute_all = 'ga', -- Substitute all
    --             }
    --         })
    --     end,
    -- },
    -- require("otavioschwanck/cool-substitute.nvim"),

    -- {
    --     "lvimuser/lsp-inlayhints.nvim",
    --     event = 'LspAttach',
    --     enabled = true,
    --     lazy = false,
    --     config = function()
    --         require("lsp-inlayhints").setup(
    --             {
    --                 only_current_line = false,
    --                 only_current_line_autocmd = "CursorHold",
    --                 show_parameter_hints = true,
    --                 parameter_hints_prefix = " ",
    --                 other_hints_prefix = " ",
    --                 max_len_align = false,
    --                 max_len_align_padding = 1,
    --                 highlight = "Comment",
    --                 enabled = true,
    --             }
    --         )
    --         vim.api.nvim_create_augroup("LspAttach_inlayhints", {})
    --         vim.api.nvim_create_autocmd("LspAttach", {
    --           group = "LspAttach_inlayhints",
    --           callback = function(args)
    --             if not (args.data and args.data.client_id) then
    --               return
    --             end
    --
    --             local bufnr = args.buf
    --             local client = vim.lsp.get_client_by_id(args.data.client_id)
    --             require("lsp-inlayhints").on_attach(client, bufnr)
    --           end,
    --         })
    --         require('lsp-inlayhints').toggle()
    --     end,
    --     opts = {
    --         inlay_hints = {
    --           parameter_hints = {
    --             remove_colon_start = false,
    --           },
    --           type_hints = {
    --             remove_colon_start = false,
    --             remove_colon_end = false,
    --           },
    --         },
    --     }
    -- },
    {
        'dgagn/diagflow.nvim',
        -- event = 'LspAttach', This is what I use personnally and it works great
        opts = {}
    }
}
