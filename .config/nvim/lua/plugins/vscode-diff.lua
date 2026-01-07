vim.api.nvim_create_user_command("CodeDiff", function(opts)
	vim.pack.add({
		{ src = "https://github.com/MunifTanjim/nui.nvim" },
		{ src = "https://github.com/esmuellert/vscode-diff.nvim" },
	})
	-- Load the plugin
	require("vscode-diff").setup()

	-- Re-run the original command
	vim.cmd({
	    cmd = "CodeDiff",
	    args = opts.fargs,
	    bang = opts.bang,
	})
end, {
	nargs = "*",
	bang = true,
	desc = "Lazy-load codediff.nvim",
})
