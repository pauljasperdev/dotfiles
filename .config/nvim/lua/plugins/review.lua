return {
	"georgeguimaraes/review.nvim",
	dependencies = {
		"esmuellert/codediff.nvim",
		"MunifTanjim/nui.nvim",
	},
	cmd = { "Review" },
	keys = {
		{ "<leader>cr", "<cmd>Review commits<cr>", desc = "Review commits" },
	},
	opts = {},
}
