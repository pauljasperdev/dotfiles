return {
	{
		"ThePrimeagen/99",
		config = function()
			local _99 = require("99")

			local cwd = vim.uv.cwd()
			local basename = vim.fs.basename(cwd)
			_99.setup({
				model = "openai/gpt-5.3-codex",

				logger = {
					level = _99.DEBUG,
					path = "/tmp/" .. basename .. ".99.debug",
					print_on_error = true,
				},

				tmp_dir = "./.tmp",

				completion = {
					custom_rules = {
						"scratch/custom_rules/",
					},
					source = "cmp",
				},

				md_files = {
					"AGENTS.md",
				},
			})

			vim.keymap.set("v", "<leader>9v", function()
				_99.visual()
			end)

			vim.keymap.set("n", "<leader>9s", function()
				_99.search()
			end)

			vim.keymap.set("n", "<leader>9x", function()
				_99.stop_all_requests()
			end)
		end,
	},
}
