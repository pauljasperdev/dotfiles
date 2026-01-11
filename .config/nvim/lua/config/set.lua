-- Leader key (used by many mappings/plugins)
vim.g.mapleader = " "

-- Clipboard
-- Use the system clipboard for all yanks/puts (requires Neovim built with +clipboard)
vim.opt.clipboard = "unnamedplus"

-- UI
vim.o.number = true -- show absolute line numbers (see NumberToggle below)
vim.o.numberwidth = 1 -- keep gutter narrow
vim.o.signcolumn = "yes" -- avoid text shifting when signs appear

-- Indentation
vim.o.tabstop = 2 -- visual width of a <Tab>
vim.o.shiftwidth = 2 -- indent size for >>/<<, autoindent, etc.
vim.o.expandtab = true -- insert spaces instead of literal tab characters
vim.o.shiftround = true -- round indents to multiples of shiftwidth
vim.opt.smartindent = true -- simple auto-indent for code-like files

-- Editing ergonomics
vim.o.mouse = "a" -- enable mouse in all modes
vim.o.wrap = true -- soft-wrap long lines
vim.opt.wrap = true -- same option via vim.opt (kept for consistency)

-- Folding
vim.o.foldlevel = 99 -- start with folds open
vim.o.foldmethod = "indent" -- fold based on indentation
vim.o.foldenable = true -- allow folding (even if currently open)

-- Search
vim.opt.hlsearch = false -- don't keep highlights after the search completes
vim.opt.incsearch = true -- show matches while typing the search

-- Files / undo
vim.opt.swapfile = false -- no swap files
vim.opt.backup = false -- no backup files
vim.opt.undodir = os.getenv("HOME") .. "/.nvim/undodir" -- persistent undo storage
vim.opt.undofile = true -- enable persistent undo

-- Scrolling / responsiveness
vim.opt.scrolloff = 8 -- keep context lines above/below cursor
vim.opt.updatetime = 50 -- faster CursorHold and related events

-- Auto-reload and local config safety
vim.opt.autoread = true -- re-read files changed outside of Neovim
vim.opt.exrc = true -- allow per-directory .nvimrc/.exrc
vim.opt.secure = true -- restrict potentially unsafe local-rc commands

-- Splits
vim.o.splitbelow = true -- horizontal splits open below
vim.o.splitright = true -- vertical splits open to the right

-- Line numbers: relative in Normal, absolute in Insert
-- Relative numbers help with motions like 5j/10k; absolute is calmer while typing.
vim.opt.number = true
vim.opt.relativenumber = true
local group = vim.api.nvim_create_augroup("NumberToggle", { clear = true })
vim.api.nvim_create_autocmd("InsertEnter", {
	group = group,
	callback = function()
		vim.opt.relativenumber = false
	end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
	group = group,
	callback = function()
		vim.opt.relativenumber = true
	end,
})

-- Highlight on yank (Catppuccin Mocha-ish yellow)
-- Defines a custom highlight group and uses it for a brief on-yank flash.
local function set_yank_highlight()
	-- mocha.yellow = #f9e2af, mocha.base = #1e1e2e
	vim.api.nvim_set_hl(0, "YankHighlight", { bg = "#f9e2af", fg = "#1e1e2e" })
end
set_yank_highlight()

local yank_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	group = yank_group,
	callback = function()
		vim.highlight.on_yank({ higroup = "YankHighlight", timeout = 600 })
	end,
})

-- Re-apply after :colorscheme (many themes redefine highlights on load)
vim.api.nvim_create_autocmd("ColorScheme", {
	group = yank_group,
	callback = set_yank_highlight,
})

-- Keep buffers in sync with disk.
-- `:checktime` updates a buffer if the file changed externally (git checkout, formatter, etc.).
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  pattern = "*",
  command = "checktime"
})

-- Also check periodically while idle/typing.
-- Note: FocusGained appears in both autocmds; that's okay (checktime is cheap).
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "FocusGained" }, {
  pattern = "*",
  command = "checktime"
})
