local opts = { noremap = true, silent = true }

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", opts)
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", opts)

vim.keymap.set("n", "L", ":cnext<CR>", opts)
vim.keymap.set("n", "H", ":cprevious<CR>", opts)

vim.keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- Completion navigation
vim.keymap.set("i", "<C-j>", "<C-n>", { noremap = true, silent = true, desc = "Next completion item" })
vim.keymap.set("i", "<C-k>", "<C-p>", { noremap = true, silent = true, desc = "Prev completion item" })
vim.keymap.set("i", "<C-Space>", "<C-x><C-o>", { noremap = true, silent = true, desc = "Trigger completion" })

vim.keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- window management
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

-- Run shell command in current file directory visual and normal mode
vim.keymap.set("v", "<leader>R", function()
	vim.ui.input({ prompt = "Command: " }, function(command)
		local dir = vim.fn.expand("%:p:h")
		if command then -- check for nil in case user cancels
			vim.cmd(string.format("!cd %s && %s", dir, command))
		end
	end)
end, opts)
vim.keymap.set("n", "<leader>R", function()
	vim.ui.input({ prompt = "Command: " }, function(command)
		local dir = vim.fn.expand("%:p:h")
		if command then -- check for nil in case user cancels
			vim.cmd(string.format("!cd %s && %s", dir, command))
		end
	end)
end, opts)

-- Toggle format-on-save (conform.nvim)
vim.keymap.set("n", "<leader>fm", function()
	vim.g.disable_autoformat = not vim.g.disable_autoformat
	if vim.g.disable_autoformat then
		vim.notify("Format on save: OFF")
	else
		vim.notify("Format on save: ON")
	end
end, { noremap = true, silent = true, desc = "Toggle format on save" })
