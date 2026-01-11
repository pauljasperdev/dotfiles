return {
	"windwp/windline.nvim",
	config = function()
		-- Windline picks a theme module based on `vim.g.colors_name`.
		-- With `colorscheme catppuccin`, it tries to load `windline.themes.catppuccin`.
		--
		-- We define it inline here (Mocha palette) so the Airline sample doesn't fall back
		-- to your terminal's very bright magenta.
		local function catppuccin_mocha_theme()
			-- Matches `/Users/paul/.config/starship.toml` (catppuccin_mocha).
			local p = {
				rosewater = "#f5e0dc",
				flamingo = "#f2cdcd",
				pink = "#f5c2e7",
				mauve = "#cba6f7",
				red = "#f38ba8",
				maroon = "#eba0ac",
				peach = "#fab387",
				yellow = "#f9e2af",
				green = "#a6e3a1",
				teal = "#94e2d5",
				sky = "#89dceb",
				sapphire = "#74c7ec",
				blue = "#89b4fa",
				lavender = "#b4befe",
				text = "#cdd6f4",
				subtext0 = "#a6adc8",
				overlay0 = "#6c7086",
				surface0 = "#313244",
				mantle = "#181825",
				base = "#1e1e2e",
				crust = "#11111b",
			}

			return {
				black = p.base,
				red = p.red,
				green = p.green,
				-- Airline sample uses yellow for Visual; Starship uses peach heavily.
				yellow = p.peach,
				blue = p.blue,
				-- Airline sample uses "magenta" for Normal-mode blocks.
				magenta = p.lavender,
				cyan = p.teal,
				white = p.text,

				black_light = p.surface0,
				red_light = p.maroon,
				yellow_light = p.yellow,
				blue_light = p.sapphire,
				magenta_light = p.mauve,
				green_light = p.teal,
				cyan_light = p.sky,
				white_light = p.subtext0,

				NormalBg = p.base,
				NormalFg = p.text,
				ActiveBg = p.surface0,
				ActiveFg = p.text,
				InactiveBg = p.mantle,
				InactiveFg = p.overlay0,
			}
		end

		-- Your `vim.g.colors_name` is `catppuccin-mocha`, so register both.
		package.preload["windline.themes.catppuccin"] = catppuccin_mocha_theme
		package.preload["windline.themes.catppuccin-mocha"] = catppuccin_mocha_theme

		-- If you change colorschemes at runtime, clear Windline's theme cache.
		vim.api.nvim_create_autocmd("ColorScheme", {
			callback = function()
				pcall(function()
					require("windline.themes").clear_cache()
				end)
			end,
		})

		require("wlsample.bubble2")
	end,
}
