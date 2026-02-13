return {
	{
		"nickjvandyke/opencode.nvim",
		dependencies = { "folke/snacks.nvim" },
		config = function()
			vim.g.opencode_opts = {
				auto_fallback_to_embedded = false,
			}

			vim.o.autoread = true
		end,
		keys = {
			{
				"<leader>oa",
				function()
					require("opencode").ask()
				end,
				desc = "Ask opencode",
				mode = "n",
			},
			{
				"<leader>oa",
				function()
					require("opencode").ask("@this: ")
				end,
				desc = "Ask opencode about selection",
				mode = "v",
			},
			{
				"<leader>oc",
				function()
					require("opencode").toggle()
				end,
				desc = "Toggle opencode",
				mode = "n",
			},
		},
	},
}
