vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
    once = true,
    callback = function(event)
        vim.pack.add({
            { src = "https://github.com/tpope/vim-sleuth" },
        }, { load = true })
        if event.event == "BufNewFile" then
            vim.schedule(function()
                vim.cmd("Sleuth")
            end)
        end
    end,
})
