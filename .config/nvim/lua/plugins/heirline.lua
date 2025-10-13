vim.pack.add({
	{ src = "https://github.com/linrongbin16/lsp-progress.nvim" },
	{ src = "https://github.com/rebelot/heirline.nvim" },
})
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("SetupHeirline", { clear = true }),
	once = true,
	callback = function()
		require("lsp-progress").setup()
		require("heirline").setup({
			statusline = require("config.heirline.statusline"),
		})
	end,
})
