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
			local function find_workspace_root(bufnr)
				local start = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
				local matches = vim.fs.find("package.json", { path = start, upward = true, stop = vim.loop.os_homedir() })
				for _, match in ipairs(matches) do
					local ok, contents = pcall(vim.fn.readfile, match)
					if ok then
						local json = table.concat(contents, "\n")
						local decoded = nil
						local ok_decode = pcall(function()
							decoded = vim.json.decode(json)
						end)
						if ok_decode and decoded and decoded.workspaces then
							return vim.fs.dirname(match)
						end
					end
				end
				return nil
			end

			local function ts_root(bufnr, on_dir)
				local workspace_root = find_workspace_root(bufnr)
				if workspace_root then
					on_dir(workspace_root)
					return
				end

				local monorepo_root = vim.fs.root(bufnr, {
					"pnpm-workspace.yaml",
					"bunfig.toml",
					"lerna.json",
					"turbo.json",
					"nx.json",
					"rush.json",
					"workspace.json",
					"moon.yml",
					"WORKSPACE",
					"WORKSPACE.bazel",
				})
				if monorepo_root then
					on_dir(monorepo_root)
					return
				end

				local dir = vim.fs.root(bufnr, { "tsconfig.json", "jsconfig.json", "package.json", ".git" })
				if dir then
					on_dir(dir)
				end
			end

			vim.lsp.config("vtsls", {
				root_dir = ts_root,
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
						experimental = {
							completion = {
								enableServerSideFuzzyMatch = true,
							},
						},
					},
					typescript = {
						updateImportsOnFileMove = { enabled = "always" },
						suggest = { completeFunctionCalls = true },
						tsserver = {
							maxTsServerMemory = 4096,
							experimental = {
								enableProjectDiagnostics = true,
							},
						},
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
