--- Detect whether the project uses biome or prettier.
--- Falls back to prettierd when no biome config is found.
---@param bufnr integer
---@return string[]
local function js_formatter(bufnr)
	if vim.fs.root(bufnr, { "biome.json", "biome.jsonc" }) then
		return { "biome" }
	end
	return { "prettierd" }
end

return {
	"stevearc/conform.nvim",
	config = function(_, opts)
		local conform = require("conform")
		conform.setup(opts)

		vim.api.nvim_create_user_command("FormatDisable", function(args)
			if args.bang then
				vim.b.disable_autoformat = true
			else
				vim.g.disable_autoformat = true
			end
		end, {
			desc = "Disable autoformat-on-save",
			bang = true,
		})
		vim.api.nvim_create_user_command("FormatEnable", function()
			vim.b.disable_autoformat = false
			vim.g.disable_autoformat = false
		end, {
			desc = "Re-enable autoformat-on-save",
		})
	end,
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			javascript = js_formatter,
			javascriptreact = js_formatter,
			typescript = js_formatter,
			typescriptreact = js_formatter,
			python = { "ruff_format" },
		},
		format_after_save = function(bufnr)
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end
			return {
				lsp_format = "fallback",
			}
		end,
	},
}
