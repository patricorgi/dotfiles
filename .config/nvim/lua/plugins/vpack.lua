local configured = false

local function load_vpack()
	if configured then
		return require("vpack")
	end

	configured = true
	vim.g.loaded_vpack = 1
	vim.pack.add({
		{ src = 'https://github.com/kouovo/vpack.nvim' }
	})

	local vpack = require("vpack")
	vpack.setup({
		window = {
			border = "rounded",
			width = 0.8,
			height = 0.8,
		},
		log = {
			path = vim.fs.joinpath(vim.fn.stdpath("log"), "nvim-pack.log"),
			border = "rounded",
			width = 0.8,
			height = 0.6,
		},
	})

	return vpack
end

vim.api.nvim_create_user_command("Vpack", function()
	load_vpack().open()
end, {
	desc = "Open vpack UI",
})
