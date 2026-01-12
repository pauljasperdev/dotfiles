return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			-- keep these deps you already had
			{ "antosha417/nvim-lsp-file-operations", config = true },
			{ "folke/lazydev.nvim", opts = {} },
		},
		config = function()
			local capabilities = vim.lsp.protocol.make_client_capabilities()

			-- Apply defaults to all servers.
			vim.lsp.config("*", {
				capabilities = capabilities,
			})

			local function root(markers)
				return function(bufnr, on_dir)
					local dir = vim.fs.root(bufnr, markers)
					if dir then
						on_dir(dir)
					end
				end
			end

			-- Python
			vim.lsp.config("pyright", {
				root_dir = root({
					"pyproject.toml",
					"pyrightconfig.json",
					"setup.py",
					"setup.cfg",
					"requirements.txt",
					"Pipfile",
					".git",
				}),
				settings = {
					python = {
						analysis = {
							typeCheckingMode = "basic",
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
						},
					},
				},
			})

			vim.lsp.config("ruff", {
				root_dir = root({ "pyproject.toml", "ruff.toml", ".git" }),
			})

			-- TypeScript / JavaScript (vtsls)
			vim.lsp.config("vtsls", {
				root_dir = root({ "package.json", "tsconfig.json", "jsconfig.json", ".git" }),
				filetypes = {
					"javascript",
					"javascriptreact",
					"javascript.jsx",
					"typescript",
					"typescriptreact",
					"typescript.tsx",
				},
				settings = {
					complete_function_calls = true,
					vtsls = {
						autoUseWorkspaceTsdk = true,
					},
					typescript = {
						updateImportsOnFileMove = { enabled = "always" },
						suggest = { completeFunctionCalls = true },
						inlayHints = {
							enumMemberValues = { enabled = true },
							functionLikeReturnTypes = { enabled = true },
							parameterNames = { enabled = "literals" },
							parameterTypes = { enabled = true },
							propertyDeclarationTypes = { enabled = true },
							variableTypes = { enabled = false },
						},
					},
					javascript = {
						inlayHints = {
							enumMemberValues = { enabled = true },
							functionLikeReturnTypes = { enabled = true },
							parameterNames = { enabled = "all" },
							parameterTypes = { enabled = true },
							propertyDeclarationTypes = { enabled = true },
							variableTypes = { enabled = true },
						},
					},
				},
			})
		end,
	},
}
