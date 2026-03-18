return {
	{
		"neovim/nvim-lspconfig",
		init = function()
			vim.lsp.config("oxc_language_server", {
				cmd = function(dispatchers, config)
					local cmd = "oxc_language_server"
					local local_cmd = (config or {}).root_dir
						and config.root_dir .. "/node_modules/.bin/oxc_language_server"
					if local_cmd and vim.fn.executable(local_cmd) == 1 then
						cmd = local_cmd
					end
					return vim.lsp.rpc.start({ cmd }, dispatchers)
				end,
				filetypes = {
					"javascript",
					"javascriptreact",
					"typescript",
					"typescriptreact",
				},
				root_markers = { "oxlintrc.json", ".oxlintrc.json", "package.json", ".git" },
			})
			vim.lsp.enable("oxc_language_server")

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

			vim.api.nvim_create_user_command("OxcFixAll", function()
				local bufnr = vim.api.nvim_get_current_buf()
				local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "oxc_language_server" })
				if #clients == 0 then
					return
				end
				vim.lsp.buf.code_action({
					context = {
						only = { "source.fixAll.oxc", "source.fixAll" },
						triggerKind = 1,
					},
					apply = true,
				})
			end, { desc = "Fix all auto-fixable OXC issues" })

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
