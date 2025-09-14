vim.pack.add({
	{ src = "https://github.com/catppuccin/nvim" },
})

require("catppuccin").setup({
	transparent_background = true,
	term_colors = true,
	integrations = {
		aerial = true,
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
		snacks = true,
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
				Pmenu = { bg = mocha.base },
			}
		end,
	},
})
vim.cmd("colorscheme catppuccin")
vim.cmd.hi("statusline guibg=NONE")
vim.cmd.hi("Comment gui=none")
