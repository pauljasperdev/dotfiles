return {
	"sindrets/diffview.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	lazy = false,
	config = function()
		require("diffview").setup({
			view = {
				default = {
					layout = "diff2_horizontal",
				},
			},
		})
	end,
	keys = {
		{ "<leader>do", "<cmd>DiffviewOpen<cr>", desc = "Working tree diff" },
		{ "<leader>dm", "<cmd>DiffviewOpen origin/main...HEAD<cr>", desc = "Diff vs main" },
		{ "<leader>dd", "<cmd>DiffviewOpen HEAD~1..HEAD<cr>", desc = "Last commit diff" },
		{ "<leader>dc", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
		{ "<leader>dh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
	},
}

