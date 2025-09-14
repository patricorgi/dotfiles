if vim.env.TMUX ~= nil and vim.env.TMUX ~= "" then
	vim.pack.add({
		"https://github.com/christoomey/vim-tmux-navigator",
	})
	vim.keymap.set("n", "<C-h>", "<cmd><C-U>TmuxNavigateLeft<cr>")
	vim.keymap.set("n", "<C-j>", "<cmd><C-U>TmuxNavigateDown<cr>")
	vim.keymap.set("n", "<C-k>", "<cmd><C-U>TmuxNavigateUp<cr>")
	vim.keymap.set("n", "<C-l>", "<cmd><C-U>TmuxNavigateRight<cr>")
else
	vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
	vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
	vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
	vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
end
