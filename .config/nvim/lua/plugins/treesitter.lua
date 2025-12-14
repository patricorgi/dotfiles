vim.pack.add({
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },
})

vim.api.nvim_create_autocmd('BufReadPre', {
    group = vim.api.nvim_create_augroup("SetupTreesitter", { clear = true }),
    once = true,
    callback = function()
        ---@diagnostic disable-next-line: missing-fields
        require('nvim-treesitter.configs').setup {
            ensure_installed = {
                'diff',
                'snakemake',
            },
            ignore_install = {
                'latex',
                'yaml',
                'xml',
            },
            auto_install = true,
            highlight = {
                enable = true,
                disable = { 'latex' },
                additional_vim_regex_highlighting = { 'ruby' },
            },
            disable = function(lang, bufnr)
                return lang == 'yaml' and vim.api.nvim_buf_line_count(bufnr) > 5000
            end,
            indent = { enable = true, disable = { 'ruby' } },
        }
        require("treesitter-context").setup({
            separator = nil,
            max_lines = 5,
            multiwindow = true,
            min_window_height = 15,
            multiline_threshold = 2,
        })
        vim.api.nvim_set_hl(0, "TreesitterContext", { link = "CursorLine" }) -- remove existing link
        vim.api.nvim_set_hl(0, "TreesitterContextBottom", {
            underline = true,
            sp = "#b4befe",
        })
        vim.keymap.set("n", "<leader>tc", "<cmd>TSContext toggle<cr>")
        -- vim.api.nvim_set_hl(0, "TreesitterContextBottom", { link = "CursorLine" }) -- remove existing link
    end,
})
