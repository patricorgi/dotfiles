local M = {}

M.is_lsp_attached = function()
	local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
	return next(clients) ~= nil
end

M.is_mac = function()
	local uname = vim.uv.os_uname()
	return uname.sysname == "Darwin"
end

M.func_on_window = function(window_name, myfunc)
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
		if ft == window_name then
			myfunc()
			break
		end
	end
end

M.reset_overseerlist_width = function()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
		if ft == "OverseerList" then
			local target_width = math.floor(vim.o.columns * 0.2)
			vim.api.nvim_win_set_width(win, target_width)
			break
		end
	end
end

return M
