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
