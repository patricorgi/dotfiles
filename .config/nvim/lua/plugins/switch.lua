vim.pack.add({
	{ src = "https://github.com/AndrewRadev/switch.vim" },
})

vim.keymap.set("n", "`", function()
	vim.cmd([[Switch]])
end, { desc = "Switch strings" })
vim.g.switch_custom_definitions = {
	{ "> [!TODO]", "> [!WIP]", "> [!DONE]", "> [!FAIL]" },
	{ "height", "width" },
}
