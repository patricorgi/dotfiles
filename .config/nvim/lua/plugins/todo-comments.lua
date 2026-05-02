local configured = false

local function load_todo_comments()
	if configured then
		return require("todo-comments")
	end

	configured = true
	vim.pack.add({
		{ src = "https://github.com/folke/todo-comments.nvim" }
	})

	local config = require("todo-comments.config")
	config._options = { signs = false }
	config._setup()

	return require("todo-comments")
end

vim.keymap.set("n", "]t", function()
	load_todo_comments().jump_next({ keywords = { "TODO", "FIXME", "HACK" } })
end, { desc = "Next todo comment" })

vim.keymap.set("n", "[t", function()
	load_todo_comments().jump_prev({ keywords = { "TODO", "FIXME", "HACK" } })
end, { desc = "Previous todo comment" })

vim.api.nvim_create_user_command("TodoQuickFix", function(opts)
	load_todo_comments()
	require("todo-comments.search").setqflist(opts.args)
end, {
	desc = "Lazy-load todo-comments.nvim",
	nargs = "*",
})

vim.api.nvim_create_user_command("TodoLocList", function(opts)
	load_todo_comments()
	require("todo-comments.search").setloclist(opts.args)
end, {
	desc = "Lazy-load todo-comments.nvim",
	nargs = "*",
})

vim.api.nvim_create_user_command("TodoTelescope", function(opts)
	load_todo_comments()
	vim.cmd("Telescope todo-comments todo " .. opts.args)
end, {
	desc = "Lazy-load todo-comments.nvim",
	nargs = "*",
})

vim.api.nvim_create_user_command("TodoFzfLua", function(_)
	load_todo_comments()
	require("todo-comments.fzf").todo()
end, {
	desc = "Lazy-load todo-comments.nvim",
	nargs = "*",
})

vim.api.nvim_create_user_command("TodoTrouble", function(opts)
	load_todo_comments()
	vim.cmd("Trouble todo " .. opts.args)
end, {
	desc = "Lazy-load todo-comments.nvim",
	nargs = "*",
})
