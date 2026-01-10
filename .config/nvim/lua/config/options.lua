-- Line numbers: relative in Normal, absolute in Insert
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

-- Highlight on yank (Catppuccin Mocha yellow)
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

-- Re-apply after :colorscheme (Catppuccin sets highlights on load)
vim.api.nvim_create_autocmd("ColorScheme", {
	group = yank_group,
	callback = set_yank_highlight,
})
