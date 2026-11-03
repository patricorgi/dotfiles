vim.g.switch_custom_definitions = {
	{ "> [!TODO]", "> [!WIP]", "> [!DONE]", "> [!FAIL]" },
	{ "- [ ]", "- [>]", "- [x]" },
	{ "height", "width" },
}

local configured = false

local function load_switch()
	if not configured then
		configured = true
		vim.pack.add({
			{ src = "https://github.com/AndrewRadev/switch.vim" },
		})
		vim.cmd("runtime plugin/switch.vim")
	end

	if vim.bo.filetype ~= "" then
		vim.cmd(("runtime! ftplugin/%s/switch.vim"):format(vim.bo.filetype))
	end
end

vim.api.nvim_create_user_command("Switch", function(opts)
	load_switch()
	vim.fn["switch#Switch"]({ count = vim.v.count1 })
end, {
	desc = "Lazy-load switch.vim",
	nargs = "*",
	range = true,
})

vim.keymap.set("n", "gs", function()
	load_switch()
	vim.fn["switch#Switch"]({ count = vim.v.count1 })
end, { desc = "Switch strings" })

vim.keymap.set("n", "`", function()
	load_switch()
	vim.fn["switch#Switch"]({ count = vim.v.count1 })
end, { desc = "Switch strings" })
