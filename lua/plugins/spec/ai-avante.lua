return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = false,
  version = "v0.0.15", -- set this if you want to always pull the latest change
  opts = {
    -- Add any configuration here
    ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
    provider = "openrouterdeepseek", -- Recommend using Claude
    -- provider = "claude", -- Recommend using Claudeava
    -- auto_suggestions_provider = "claude", -- Since auto-suggestions are a high-frequency operation and therefore expensive, it is recommended to specify an inexpensive provider or even a free provider: copilot
    vendors = {
      openrouterdeepseek = {
        endpoint = "https://openrouter.ai/api",
        -- model = "deepseek/deepseek-r1",
        model = "deepseek/deepseek-r1-distill-llama-70b",
        api_key_name = "OPENROUTER_API_KEY",
        parse_curl_args = function(opts, code_opts)
          --[[ local messages = {}
          local first_msg = { role = "system", content = code_opts.system_prompt }
          table.insert(messages, first_msg)
          if code_opts.messages then
            table.insert(messages, require("avante.providers.openai").parse_messages(code_opts))
            --[[ local content = ""
                for idx, msg in ipairs(code_opts.) do
                  if content == "" then
                    content = content .. msg.content
                  else
                    content = content .. "\n" .. msg.content
                  end
                end
                local next_msg = { role = "user", content = content }
                table.insert(messages, next_msg) ]]
          local messages = require("avante.providers.openai").parse_messages(code_opts)
          return {
            url = opts.endpoint .. "/v1/chat/completions",
            headers = {
              -- ["Accept"] = "application/json",
              ["Content-Type"] = "application/json",
              ["Authorization"] = "Bearer " .. os.getenv(opts.api_key_name),
            },
            insecure = true,
            body = {
              model = opts.model,
              provider = {
                ["allow_fallbacks"] = false,
                ["order"] = { "DeepSeek", "DeepInfra" },
              },
              messages = messages,
              temperature = 0,
              max_tokens = 8192,
              stream = true, -- this will be set by default.
            },
          }
        end,
        -- The below function is used if the vendors has specific SSE spec that is not claude or openai.
        parse_response_data = function(data_stream, event_state, opts)
          require("avante.providers.openai").parse_response(data_stream, event_state, opts)
        end,
      },
      openrouterclaude = {
        endpoint = "https://openrouter.ai/api",
        model = "anthropic/claude-3-5-haiku",
        api_key_name = "OPENROUTER_API_KEY",
        parse_curl_args = function(opts, code_opts)
          --[[ local messages = {}
          local first_msg = { role = "system", content = code_opts.system_prompt }
          table.insert(messages, first_msg)
          if code_opts.messages then
            table.insert(messages, require("avante.providers.openai").parse_messages(code_opts))
            --[[ local content = ""
                for idx, msg in ipairs(code_opts.) do
                  if content == "" then
                    content = content .. msg.content
                  else
                    content = content .. "\n" .. msg.content
                  end
                end
                local next_msg = { role = "user", content = content }
                table.insert(messages, next_msg) ]]
          local messages = require("avante.providers.openai").parse_messages(code_opts)
          return {
            url = opts.endpoint .. "/v1/chat/completions",
            headers = {
              -- ["Accept"] = "application/json",
              ["Content-Type"] = "application/json",
              ["Authorization"] = "Bearer " .. os.getenv(opts.api_key_name),
            },
            insecure = true,
            body = {
              model = opts.model,
              messages = messages,
              temperature = 0,
              max_tokens = 8192,
              stream = true, -- this will be set by default.
            },
          }
        end,
        -- The below function is used if the vendors has specific SSE spec that is not claude or openai.
        parse_response_data = function(data_stream, event_state, opts)
          require("avante.providers.openai").parse_response(data_stream, event_state, opts)
        end,
      },
    },
    claude = {
      -- anthropic
      endpoint = "https://api.anthropic.com",
      model = "claude-3-5-sonnet-20241022",
      temperature = 0,
      max_tokens = 4096,
    },
    openai = {
      endpoint = "https://openrouter.ai/api/v1",
      model = "gpt-3.5-turbo",
      temperature = 0,
      max_tokens = 4096,
    },
    behaviour = {
      auto_suggestions = false, -- Experimental stage
      auto_set_highlight_group = true,
      auto_set_keymaps = true,
      auto_apply_diff_after_generation = false,
      support_paste_from_clipboard = false,
    },
    mappings = {
      --- @class AvanteConflictMappings
      diff = {
        ours = "co",
        theirs = "ct",
        all_theirs = "ca",
        both = "cb",
        cursor = "cc",
        next = "]x",
        prev = "[x",
      },
      suggestion = {
        accept = "<M-l>",
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
      },
      jump = {
        next = "]]",
        prev = "[[",
      },
      submit = {
        normal = "<CR>",
        insert = "<C-s>",
      },
      sidebar = {
        apply_all = "<leader>-A",
        apply_cursor = "a",
        switch_windows = "<Tab>",
        reverse_switch_windows = "<S-Tab>",
      },
    },
    hints = { enabled = true },
    windows = {
      ---@type "right" | "left" | "top" | "bottom"
      position = "right", -- the position of the sidebar
      wrap = true, -- similar to vim.o.wrap
      width = 30, -- default % based on available width
      sidebar_header = {
        enabled = true, -- true, false to enable/disable the header
        align = "center", -- left, center, right for title
        rounded = true,
      },
      input = {
        prefix = "> ",
      },
      edit = {
        border = "rounded",
        start_insert = true, -- Start insert mode when opening the edit window
      },
      ask = {
        floating = false, -- Open the 'AvanteAsk' prompt in a floating window
        start_insert = true, -- Start insert mode when opening the ask window, only effective if floating = true.
        border = "rounded",
      },
    },
    highlights = {
      ---@type AvanteConflictHighlights
      diff = {
        current = "DiffText",
        incoming = "DiffAdd",
      },
    },
    --- @class AvanteConflictUserConfig
    diff = {
      autojump = true,
      ---@type string | fun(): any
      list_opener = "copen",
    },
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "echasnovski/mini.pick", -- for file_selector provider mini.pick
    "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
    "ibhagwan/fzf-lua", -- for file_selector provider fzf
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
