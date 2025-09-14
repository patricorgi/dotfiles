if vim.b.did_my_ftplugin then
	return
end
vim.b.did_my_ftplugin = true

if vim.fn.executable("prettierd") == 1 then
	vim.keymap.set("n", "<leader>lf", function()
		local pos = vim.api.nvim_win_get_cursor(0)
		local filepath = vim.fn.shellescape(vim.fn.expand("%:p"))
		vim.cmd("%!prettierd --stdin-filepath " .. filepath)
		vim.cmd("write")
		vim.api.nvim_win_set_cursor(0, pos)
	end, { desc = "Format current buffer with prettierd", buffer = true })
end
