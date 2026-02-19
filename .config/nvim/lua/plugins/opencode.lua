vim.pack.add({
	{ src = "https://github.com/nickjvandyke/opencode.nvim" },
})

local opencode = require("opencode")

vim.keymap.set("n", "<leader>oa", function()
	opencode.ask("@buffer: ")
end)

vim.keymap.set("v", "<leader>oa", function()
	opencode.ask("@this: ")
end)

