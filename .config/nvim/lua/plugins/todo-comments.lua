vim.pack.add({
    { src = "https://github.com/folke/todo-comments.nvim" }
})


vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("SetupTodoComments", { clear = true }),
	once = true,
	callback = function()
        require("todo-comments").setup({
            signs = false
        })
        vim.keymap.set("n", "]t", function()
          require("todo-comments").jump_next({keywords = { "TODO", "FIXME", "HACK" }})
        end, { desc = "Next todo comment" })
        
        vim.keymap.set("n", "[t", function()
          require("todo-comments").jump_prev({keywords = { "TODO", "FIXME", "HACK" }})
        end, { desc = "Previous todo comment" })
	end,
})
