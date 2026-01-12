return {
	-- Treesitter rewrite (Neovim 0.11+)
	-- This plugin manages parsers + query bundles.
	-- Treesitter highlighting itself is provided by Neovim and must be started with `vim.treesitter.start()`.
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	cmd = { "TSInstall", "TSUpdate", "TSUninstall", "TSLog" },
	config = function()
		local ts = require("nvim-treesitter")

		-- Optional: override install dir; default is stdpath('data') .. '/site'
		ts.setup({
			install_dir = vim.fn.stdpath("data") .. "/site",
		})

		-- Keep this list in one place; it drives parser installation and auto-start.
		local langs = {
			"bash",
			"c",
			"css",
			"dockerfile",
			"graphql",
			"html",
			"javascript",
			"json",
			"lua",
			"markdown",
			"markdown_inline",
			"prisma",
			"python",
			"query",
			"svelte",
			"toml",
			"tsx",
			"typescript",
			"vim",
			"vimdoc",
			"yaml",
		}

		-- Install missing parsers (async).
		local ok_installed, installed = pcall(ts.get_installed, "parsers")
		local installed_set = {}
		if ok_installed and type(installed) == "table" then
			for _, lang in ipairs(installed) do
				installed_set[lang] = true
			end
		end

		local to_install = vim.tbl_filter(function(lang)
			return not installed_set[lang]
		end, langs)

		if #to_install > 0 then
			pcall(function()
				ts.install(to_install, { summary = true })
			end)
		end

		-- Use bash parser for zsh files
		vim.treesitter.language.register("bash", "zsh")

		-- Start treesitter highlighting for supported filetypes.
		-- (Treesitter rewrite does not enable highlighting automatically.)
		local ft_group = vim.api.nvim_create_augroup("UserTreesitterStart", { clear = true })
		vim.api.nvim_create_autocmd("FileType", {
			group = ft_group,
			pattern = {
				"bash",
				"c",
				"css",
				"dockerfile",
				"graphql",
				"html",
				"javascript",
				"javascriptreact",
				"json",
				"lua",
				"markdown",
				"prisma",
				"python",
				"svelte",
				"toml",
				"typescript",
				"typescriptreact",
				"vim",
				"vimdoc",
				"yaml",
				"zsh",
			},
			callback = function(ev)
				local ft = vim.bo[ev.buf].filetype
				local lang = vim.treesitter.language.get_lang(ft)
				if not lang then
					return
				end

				pcall(vim.treesitter.start, ev.buf, lang)
			end,
		})
	end,
}
