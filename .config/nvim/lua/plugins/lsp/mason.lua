return {
	{
		"mason-org/mason.nvim",
		cmd = "Mason",
		opts = {
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {
			ensure_installed = {
				-- TS / JS
				"vtsls",
				-- Python
				"pyright",
				"ruff",

				-- Keep existing servers you already used
				"lua_ls",
				"html",
				"cssls",
				"tailwindcss",
				"svelte",
				"graphql",
				"emmet_ls",
				"prismals",
				"eslint",
			},
			-- Mason v2: automatically enable servers after installation
			automatic_enable = true,
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = {
			"mason-org/mason.nvim",
		},
		opts = {
			ensure_installed = {
				"prettier",
				"stylua",
				-- Python tooling
				"ruff",
				"isort",
				"black",
				"pylint",
				"eslint_d",
			},
		},
	},
}
