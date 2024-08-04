require("globals")

local options = {
	guicursor = "", -- disable cursor styling
	cursorline = false, -- disable cursor styling
	completeopt = { "menuone", "noselect" }, -- options for insert mode completion (for cmp plugin)
	conceallevel = 0, -- so that `` is visible in markdown files
	cmdheight = 2, -- number of of screen lines to use for the command line
	relativenumber = true, -- relative numbers from line cursor is on
	swapfile = false,
	hlsearch = true, -- highlight all matches of previous search pattern
	incsearch = true, -- highlight matches of current search pattern as it is typed
	scrolloff = 8, -- minimal number of screen lines to keep above and below the cursor.
	-- smarttab = true,
	tabstop = 4, -- number of spaces to insert for a tab
	shiftwidth = 4, -- number of spaces inserted for each indentation
	undofile = true, -- keep undo history between sessions
	backup = false, -- Some servers have issues with backup files, see #649.
	writebackup = false,
}

for key, value in pairs(options) do
	vim.opt[key] = value
end

vim.opt.shortmess:append("c") -- hide startup message

-- highlight yank
vim.cmd([[
augroup highlight_yank
    autocmd!
    autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank({timeout = 80})
augroup END
]])

-- wrap git commit body message lines at 72 characters
vim.cmd([["
    augroup gitsetup
        autocmd!
        autocmd FileType gitcommit
                \ autocmd CursorMoved,CursorMovedI * 
                        \ let &l:textwidth = line('.') == 1 ? 50 : 72
augroup end
"]])
--
-- vim.cmd([[
-- augroup goformat
--     autocmd!
--     autocmd("BufWritePre", {
--     pattern = "*.go",
--     callback = function()
--       local params = vim.lsp.util.make_range_params()
--       params.context = {only = {"source.organizeImports"}}
--       -- buf_request_sync defaults to a 1000ms timeout. Depending on your
--       -- machine and codebase, you may want longer. Add an additional
--       -- argument after params if you find that you have to write the file
--       -- twice for changes to be saved.
--       -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
--       local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
--       for cid, res in pairs(result or {}) do
--         for _, r in pairs(res.result or {}) do
--           if r.edit then
--             local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
--             vim.lsp.util.apply_workspace_edit(r.edit, enc)
--           end
--         end
--       end
--       vim.lsp.buf.format({async = false})
--     end
--     })
--
-- ]])


local enable_providers = {
	"python3_provider",
	-- and so on
}

for _, plugin in pairs(enable_providers) do
	vim.g["loaded_" .. plugin] = nil
	vim.cmd("runtime " .. plugin)
end

vim.g.python3_host_prog = "/bin/python3"

-- dofile(vim.g.base46_cache .. "syntax")
