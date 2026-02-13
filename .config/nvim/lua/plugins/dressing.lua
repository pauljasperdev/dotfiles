return {
	"stevearc/dressing.nvim",
	opts = {
		select = {
			backend = { "builtin" },
			builtin = {
				border = "rounded",
				relative = "editor",
				min_width = 50,
				max_width = 120,
			},
		},
		input = {
			border = "rounded",
		},
	},
}
