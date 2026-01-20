return {
	"pauljasperdev/review.nvim",
	dependencies = {
		"esmuellert/codediff.nvim",
		"MunifTanjim/nui.nvim",
	},
	cmd = { "Review" },
	keys = {
		{ "<leader>cr", "<cmd>Review commits<cr>", desc = "Review commits" },
	},
	opts = {},
	config = function(_, opts)
		require("review").setup(opts)

		local keymapped_buffers = {}

		local function project_root()
			return vim.fs.root(0, { ".git" }) or vim.fn.getcwd()
		end

		local function write_code_review()
			local markdown = require("review.export").generate_markdown()
			local root = project_root()
			local path = root .. "/CODE_REVIEW.md"

			vim.fn.writefile(vim.split(markdown, "\n", { plain = true }), path)
			vim.notify("Wrote review to " .. path, vim.log.levels.INFO, { title = "Review" })
		end

		local function maybe_set_keymap(bufnr)
			if keymapped_buffers[bufnr] then
				return
			end

			vim.keymap.set("n", "W", write_code_review, {
				buffer = bufnr,
				noremap = true,
				silent = true,
				nowait = true,
				desc = "Write CODE_REVIEW.md",
			})

			keymapped_buffers[bufnr] = true
		end

		local augroup = vim.api.nvim_create_augroup("dotfiles_review_code_review", { clear = true })
		vim.api.nvim_create_autocmd({ "TabEnter", "BufEnter" }, {
			group = augroup,
			callback = function()
				local ok, lifecycle = pcall(require, "codediff.ui.lifecycle")
				if not ok then
					return
				end

				local tabpage = vim.api.nvim_get_current_tabpage()
				if not lifecycle.get_session(tabpage) then
					return
				end

				maybe_set_keymap(vim.api.nvim_get_current_buf())
			end,
		})
	end,
}
