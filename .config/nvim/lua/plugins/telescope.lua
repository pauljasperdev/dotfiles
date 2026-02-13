return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"debugloop/telescope-undo.nvim",
		"isak102/telescope-git-file-history.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},
	lazy = false,
	opts = {
		pickers = {
			find_files = {
				hidden = true,
			},
			git_files = {
				hidden = true,
			},
		},
		defaults = {
			mappings = {
				i = {
					["<C-j>"] = require("telescope.actions").move_selection_next,
					["<C-k>"] = require("telescope.actions").move_selection_previous,
				},
				n = {
					["<C-j>"] = require("telescope.actions").move_selection_next,
					["<C-k>"] = require("telescope.actions").move_selection_previous,
				},
			},
			file_ignore_patterns = {
				"node_modules/*",
				".repos/*",
			},
		},
		extensions = {
			fzf = {},
		},
	},
	config = function(_, opts)
		require("telescope").setup(opts)
		require("telescope").load_extension("undo")
		require("telescope").load_extension("fzf")
		require("telescope").load_extension("git_file_history")
	end,
	keys = {
		{ "<leader>ff", "<cmd>Telescope git_files<cr>", desc = "Find files" },
		{ "<leader>fa", "<cmd>Telescope find_files<cr>", desc = "Find all files" },
		{ "<leader>fs", "<cmd>Telescope live_grep<cr>", desc = "Find in files" },
	},
}
