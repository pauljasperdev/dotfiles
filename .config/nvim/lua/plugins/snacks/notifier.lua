return {
	"folke/snacks.nvim",
	init = function()
		vim.api.nvim_create_autocmd("LspProgress", {
			desc = "Show language server progress",
			callback = function(args)
				local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
				vim.notify(vim.lsp.status(), "info", {
					id = "lsp_progress",
					title = "LSP Progress",
					opts = function(notif)
						notif.icon = args.data.params.value.kind == "end" and " "
							or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
					end,
				})
			end,
		})
	end,
	opts = {
		notifier = {
			enabled = true,
			timeout = 3000,
		},
	},
}
