if vim.b.did_my_ftplugin then
	return
end
vim.b.did_my_ftplugin = true

vim.lsp.enable("tinymist")
vim.lsp.enable("typstyle")

if vim.fn.executable("typstyle") == 1 then
	vim.keymap.set("n", "<leader>lf", function()
		local pos = vim.api.nvim_win_get_cursor(0)
		vim.cmd("%!typstyle")
		vim.cmd("write")
		vim.api.nvim_win_set_cursor(0, pos)
	end, { desc = "Format current buffer with typstyle", buffer = true })
end

-- only if you are using zathura
local typst_job_id = nil
vim.keymap.set("n", "<leader>tw", function()
	local src = vim.fn.expand("%:p")
	local pdf = vim.fn.expand("%:p:r") .. ".pdf"
	-- Start typst watch only if not already running
	if not typst_job_id or vim.fn.jobwait({ typst_job_id }, 0)[1] ~= -1 then
		typst_job_id = vim.fn.jobstart(
			{ "typst", "watch", "--diagnostic-format", "short", src },
			{ stdout_buffered = true, stderr_buffered = true } -- no detach = killed with nvim
		)
	end
	-- (Re)open zathura every time
	vim.fn.jobstart({ "zathura", pdf })
end, { buffer = true, desc = "Start typst watch and open PDF in zathura" })
