if vim.env.TMUX ~= nil and vim.env.TMUX ~= "" then
	vim.g.tmux_navigator_no_mappings = 1
	local loaded = false
	local function navigate(command)
		if not loaded then
			vim.pack.add({
				"https://github.com/christoomey/vim-tmux-navigator",
			}, { load = true })
			loaded = true
		end
		vim.cmd(command)
	end

	vim.keymap.set("n", "<M-h>", function() navigate("TmuxNavigateLeft") end)
	vim.keymap.set("n", "<M-j>", function() navigate("TmuxNavigateDown") end)
	vim.keymap.set("n", "<M-k>", function() navigate("TmuxNavigateUp") end)
	vim.keymap.set("n", "<M-l>", function() navigate("TmuxNavigateRight") end)
else
	vim.keymap.set("n", "<M-h>", "<C-w>h", { desc = "Go to left window" })
	vim.keymap.set("n", "<M-j>", "<C-w>j", { desc = "Go to lower window" })
	vim.keymap.set("n", "<M-k>", "<C-w>k", { desc = "Go to upper window" })
	vim.keymap.set("n", "<M-l>", "<C-w>l", { desc = "Go to right window" })
end
