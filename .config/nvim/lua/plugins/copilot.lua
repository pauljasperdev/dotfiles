return {
	{
		"github/copilot.vim",
		init = function()
			vim.g.copilot_no_tab_map = true
		end,
		config = function()
			vim.keymap.set("i", "<Tab>", 'copilot#Accept("")', {
				expr = true,
				replace_keycodes = false,
				silent = true,
				desc = "Accept Copilot suggestion",
			})
		end,
	},
}
