return {
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")
			lspconfig.oxc_language_server.setup({})

			local group = vim.api.nvim_create_augroup("OxlintFixOnSave", { clear = true })
			vim.api.nvim_create_autocmd("BufWritePost", {
				group = group,
				pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.mjs", "*.cjs", "*.mts", "*.cts" },
				callback = function(ev)
					local bufnr = ev.buf
					if vim.g.disable_oxlint_fix or vim.b[bufnr].disable_oxlint_fix then
						return
					end
					local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "oxc_language_server" })
					if #clients == 0 then
						return
					end
					vim.schedule(function()
						vim.cmd("OxcFixAll")
					end)
				end,
			})

			vim.api.nvim_create_user_command("OxlintFixDisable", function(args)
				if args.bang then
					vim.b.disable_oxlint_fix = true
				else
					vim.g.disable_oxlint_fix = true
				end
			end, {
				desc = "Disable OxcFixAll on save",
				bang = true,
			})

			vim.api.nvim_create_user_command("OxlintFixEnable", function()
				vim.b.disable_oxlint_fix = false
				vim.g.disable_oxlint_fix = false
			end, {
				desc = "Enable OxcFixAll on save",
			})
		end,
	},
}
