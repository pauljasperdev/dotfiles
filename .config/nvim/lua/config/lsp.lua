local keymap = vim.keymap -- for conciseness
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Buffer local mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local opts = { buffer = ev.buf, silent = true }
		local telescope_builtin = require("telescope.builtin")
		local telescope_lsp_opts = { file_ignore_patterns = {} }

		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client and client.name == "ruff" then
			-- Prefer Pyright hover over Ruff hover
			client.server_capabilities.hoverProvider = false
		end

		-- set keybinds
		opts.desc = "Show LSP references"
		keymap.set("n", "gr", function()
			telescope_builtin.lsp_references(telescope_lsp_opts)
		end, opts) -- show definition, references

		opts.desc = "Go to declaration"
		keymap.set("n", "gD", function()
			telescope_builtin.lsp_declarations(vim.tbl_extend("force", telescope_lsp_opts, { jump_type = "never" }))
		end, opts) -- go to declaration

		opts.desc = "Show LSP definitions"
		keymap.set("n", "gd", function()
			telescope_builtin.lsp_definitions(vim.tbl_extend("force", telescope_lsp_opts, { jump_type = "never" }))
		end, opts) -- show lsp definitions

		opts.desc = "Show LSP implementations"
		keymap.set("n", "gi", function()
			telescope_builtin.lsp_implementations(vim.tbl_extend("force", telescope_lsp_opts, { jump_type = "never" }))
		end, opts) -- show lsp implementations

		opts.desc = "Show LSP type definitions"
		keymap.set("n", "gt", function()
			telescope_builtin.lsp_type_definitions(vim.tbl_extend("force", telescope_lsp_opts, { jump_type = "never" }))
		end, opts) -- show lsp type definitions

		opts.desc = "Show document symbols"
		keymap.set("n", "<leader>ls", "<cmd>Telescope lsp_document_symbols<CR>", opts)

		opts.desc = "Show workspace symbols"
		keymap.set("n", "<leader>lS", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", opts)

		opts.desc = "Show incoming calls"
		keymap.set("n", "<leader>li", "<cmd>Telescope lsp_incoming_calls<CR>", opts)

		opts.desc = "Show outgoing calls"
		keymap.set("n", "<leader>lo", "<cmd>Telescope lsp_outgoing_calls<CR>", opts)

		opts.desc = "See available code actions"
		keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

		opts.desc = "Smart rename"
		keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

		opts.desc = "Show buffer diagnostics"
		keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

		opts.desc = "Show line diagnostics"
		keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line


		opts.desc = "Go to previous diagnostic"
		keymap.set("n", "[d", function()
			vim.diagnostic.jump({ count = -1, float = true })
		end, opts) -- jump to previous diagnostic in buffer
		--
		opts.desc = "Go to next diagnostic"
		keymap.set("n", "]d", function()
			vim.diagnostic.jump({ count = 1, float = true })
		end, opts) -- jump to next diagnostic in buffer

		opts.desc = "Show documentation for what is under cursor"
		keymap.set("n", "gh", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

		opts.desc = "Restart LSP"
		keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
	end,
})

-- vim.lsp.inlay_hint.enable(true)

local severity = vim.diagnostic.severity

vim.diagnostic.config({
	signs = {
		text = {
			[severity.ERROR] = " ",
			[severity.WARN] = " ",
			[severity.HINT] = "󰠠 ",
			[severity.INFO] = " ",
		},
	},
	float = {
		border = "rounded",
		source = "if_many",
	},
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	border = "rounded",
})
