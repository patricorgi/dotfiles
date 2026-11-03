vim.pack.add({
	{ src = "https://github.com/catppuccin/nvim" },
})

require("catppuccin").setup({
	transparent_background = true,
	term_colors = true,
	default_integrations = false,
	integrations = {
		aerial = true,
		dap = true,
		dap_ui = true,
		diffview = true,
		mini = {
			enabled = true,
			indentscope_color = "sky",
		},
		noice = true,
		-- overseer = true,
		telescope = {
			enabled = true,
			-- style = "nvchad",
		},
		treesitter = true,
		notify = true,
		gitsigns = true,
		flash = true,
		blink_cmp = true,
		mason = true,
		render_markdown = true,
		snacks = true,
		treesitter_context = true,
	},
	highlight_overrides = {
		mocha = function(mocha)
			return {
				CursorLineNr = { fg = mocha.yellow },
				TelescopeSelection = { bg = mocha.surface0 },
				TelescopeSelectionCaret = { fg = mocha.yellow, bg = mocha.surface0 },
				TelescopePromptPrefix = { fg = mocha.yellow },
				FlashCurrent = { bg = mocha.peach, fg = mocha.base },
				FlashMatch = { bg = mocha.red, fg = mocha.base },
				FlashLabel = { bg = mocha.teal, fg = mocha.base },
				NormalFloat = { bg = mocha.base },
				FloatBorder = { bg = mocha.base },
				FloatTitle = { bg = mocha.base },
				RenderMarkdownCode = { bg = mocha.crust },
				Pmenu = { bg = mocha.surface0 },
                Comment = { bg = nil },
                statusline = { bg = nil }
			}
		end,
	},
})
vim.cmd("colorscheme catppuccin")
