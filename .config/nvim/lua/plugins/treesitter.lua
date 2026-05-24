vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
    group = vim.api.nvim_create_augroup("SetupTreesitter", { clear = true }),
    once = true,
    callback = function()
        vim.pack.add({
            { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
            { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },
        })
        require('nvim-treesitter').setup({})
        require('nvim-treesitter').install { 'diff', 'snakemake' }
        require("treesitter-context").setup({
            enable = false,
            separator = nil,
            max_lines = 5,
            multiwindow = true,
            min_window_height = 15,
            multiline_threshold = 2,
        })
        vim.api.nvim_set_hl(0, "TreesitterContext", { link = "CursorLine" }) -- remove existing link
        vim.api.nvim_set_hl(0, "TreesitterContextBottom", {
            -- underline = true,
            sp = "#b4befe",
        })
        vim.keymap.set("n", "<leader>tc", "<cmd>TSContext toggle<cr>")
        -- vim.api.nvim_set_hl(0, "TreesitterContextBottom", { link = "CursorLine" }) -- remove existing link
    end,
})
