return {
	{
		"saghen/blink.cmp",
		version = "1.*",
		event = "InsertEnter",
		opts = {
			appearance = {
				nerd_font_variant = "mono",
			},
			completion = {
				list = {
					selection = {
						preselect = false,
					},
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 100,
					window = { border = "rounded" },
				},
				menu = {
					border = "rounded",
				},
				trigger = {
					show_in_snippet = false,
				},
			},
			fuzzy = {
				implementation = "prefer_rust",
			},
			keymap = {
				preset = "default",
				["<CR>"] = { "accept", "fallback" },
				["<C-j>"] = { "select_next", "fallback" },
				["<C-k>"] = { "select_prev", "fallback" },
				["<C-d>"] = { "scroll_documentation_down", "fallback" },
				["<C-u>"] = { "scroll_documentation_up", "fallback" },
				["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
				["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
			},
			signature = {
				enabled = true,
			},
			sources = {
				default = { "lsp", "buffer", "snippets", "path" },
				providers = {
					lsp = {
						score_offset = 4,
					},
					snippets = {
						score_offset = 5,
						should_show_items = function(ctx)
							return not (
								ctx.trigger.initial_kind == "manual"
								or ctx.trigger.initial_kind == "trigger_character"
							)
						end,
					},
				},
			},
		},
	},
}
