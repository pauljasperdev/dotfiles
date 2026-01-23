return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			-- keep these deps you already had
			{ "antosha417/nvim-lsp-file-operations", config = true },
			{ "folke/lazydev.nvim", opts = {} },
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Apply defaults to all servers.
			vim.lsp.config("*", {
				capabilities = capabilities,
			})

			local function read_file(path)
				local ok, contents = pcall(vim.fn.readfile, path)
				if not ok then
					return nil
				end
				return table.concat(contents, "\n")
			end

			local function find_uv_workspace_root(bufnr)
				local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
				local home = vim.loop.os_homedir()
				local uv_root = nil
				while dir and dir ~= "" and dir ~= home do
					local candidate = dir .. "/pyproject.toml"
					local text = read_file(candidate)
					if text and text:match("%[tool%.uv%.workspace%]") then
						uv_root = dir
					end
					local parent = vim.fs.dirname(dir)
					if parent == dir then
						break
					end
					dir = parent
				end
				return uv_root
			end

			local function parse_uv_workspace_members(root_dir)
				local text = read_file(root_dir .. "/pyproject.toml")
				if not text then
					return {}
				end
				local section = text:match("%[tool%.uv%.workspace%](.-)%[")
				if not section then
					section = text:match("%[tool%.uv%.workspace%](.*)")
				end
				if not section then
					return {}
				end
				local members = {}
				for member in section:gmatch('"(.-)"') do
					table.insert(members, member)
				end
				return members
			end

			local function is_ignored_path(path)
				return path:find("/%.venv/")
					or path:find("/%.git/")
					or path:find("/node_modules/")
					or path:find("/dist/")
			end

			local function find_python_extra_paths(root_dir)
				local extra_paths = {}
				local members = parse_uv_workspace_members(root_dir)
				if #members > 0 then
					for _, member in ipairs(members) do
						local member_root = root_dir .. "/" .. member
						local member_src = member_root .. "/src"
						if vim.fn.isdirectory(member_src) == 1 then
							table.insert(extra_paths, member_src)
						elseif vim.fn.isdirectory(member_root) == 1 then
							table.insert(extra_paths, member_root)
						end
					end
					return extra_paths
				end

				local src_dirs = vim.fs.find("src", { path = root_dir, type = "directory", limit = 200 })
				for _, src_dir in ipairs(src_dirs) do
					if not is_ignored_path(src_dir) then
						table.insert(extra_paths, src_dir)
					end
				end
				return extra_paths
			end

			local function apply_pyright_settings(target, root_dir)
				local uv_root = find_uv_workspace_root(vim.api.nvim_get_current_buf()) or root_dir
				local extra_paths = find_python_extra_paths(uv_root)
				local venv_python = uv_root .. "/.venv/bin/python"
				if vim.fn.filereadable(venv_python) ~= 1 then
					venv_python = vim.fn.exepath("python3")
					if venv_python == "" then
						venv_python = vim.fn.exepath("python")
					end
				end
				target.settings = target.settings or {}
				local python_settings = target.settings.python or {}
				python_settings.venvPath = uv_root
				python_settings.venv = ".venv"
				python_settings.pythonPath = venv_python
				python_settings.analysis = python_settings.analysis or {}
				if #extra_paths > 0 then
					python_settings.analysis.extraPaths = extra_paths
				end
				target.settings.python = python_settings
			end

			-- Python
			vim.lsp.config("pyright", {
				root_dir = function(bufnr, on_dir)
					local uv_root = find_uv_workspace_root(bufnr)
					if uv_root then
						on_dir(uv_root)
						return uv_root
					end

					local dir = vim.fs.root(bufnr, {
						"pyproject.toml",
						"pyrightconfig.json",
						"setup.py",
						"setup.cfg",
						"requirements.txt",
						"Pipfile",
						".git",
					})
					if dir then
						on_dir(dir)
						return dir
					end
				end,
				on_init = function(client)
					apply_pyright_settings(client.config, client.config.root_dir)
					client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
				end,
				on_new_config = function(new_config, root_dir)
					apply_pyright_settings(new_config, root_dir)
				end,
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
				root_dir = function(bufnr, on_dir)
					local uv_root = find_uv_workspace_root(bufnr)
					if uv_root then
						on_dir(uv_root)
						return
					end

					local dir = vim.fs.root(bufnr, { "pyproject.toml", "ruff.toml", ".git" })
					if dir then
						on_dir(dir)
					end
				end,
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
