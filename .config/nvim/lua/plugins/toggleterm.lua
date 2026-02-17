return {
	"akinsho/toggleterm.nvim",
	version = "*",
	opts = {
		size = 15,
		direction = "horizontal",
		shade_terminals = true,
	},
	keys = {
		{
			"<A-i>",
			"<cmd>ToggleTerm<cr>",
			desc = "Toggle terminal",
			mode = { "n", "t" },
		},
	},
}
