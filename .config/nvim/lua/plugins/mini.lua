vim.pack.add({
	{ src = "https://github.com/nvim-mini/mini.ai" },
	{ src = "https://github.com/nvim-mini/mini.icons" },
	{ src = "https://github.com/nvim-mini/mini.surround" },
})

-- Mini
require("mini.ai").setup({
	mappings = {
		goto_left = "[",
		got_right = "]",
	},
})
require("mini.icons").setup({
	style = "glyph",
	file = {
		README = { glyph = "󰆈", hl = "MiniIconsYellow" },
		["README.md"] = { glyph = "󰆈", hl = "MiniIconsYellow" },
	},
	filetype = {
		bash = { glyph = "󱆃", hl = "MiniIconsGreen" },
		sh = { glyph = "󱆃", hl = "MiniIconsGrey" },
		toml = { glyph = "󱄽", hl = "MiniIconsOrange" },
	},
})
require("mini.surround").setup({
	mappings = {
		add = "sa", -- Add surrounding in Normal and Visual modes
		delete = "sd", -- Delete surrounding
		find = "sf", -- Find surrounding (to the right)
		find_left = "sF", -- Find surrounding (to the left)
		highlight = "sh", -- Highlight surrounding
		replace = "sr", -- Replace surrounding
		update_n_lines = "sn", -- Update `n_lines`

		suffix_last = "l", -- Suffix to search with "prev" method
		suffix_next = "n", -- Suffix to search with "next" method
	},
})
