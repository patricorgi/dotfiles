if vim.env.TMUX ~= nil and vim.env.TMUX ~= "" then
	vim.pack.add({
		"https://github.com/christoomey/vim-tmux-navigator",
	})
	vim.keymap.set("n", "<M-h>", "<cmd>TmuxNavigateLeft<cr>")
	vim.keymap.set("n", "<M-j>", "<cmd>TmuxNavigateDown<cr>")
	vim.keymap.set("n", "<M-k>", "<cmd>TmuxNavigateUp<cr>")
	vim.keymap.set("n", "<M-l>", "<cmd>TmuxNavigateRight<cr>")
else
	vim.keymap.set("n", "<M-h>", "<C-w>h", { desc = "Go to left window" })
	vim.keymap.set("n", "<M-j>", "<C-w>j", { desc = "Go to lower window" })
	vim.keymap.set("n", "<M-k>", "<C-w>k", { desc = "Go to upper window" })
	vim.keymap.set("n", "<M-l>", "<C-w>l", { desc = "Go to right window" })
end
