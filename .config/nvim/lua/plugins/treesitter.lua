local treesitter_loaded = false
local context_loaded = false

local function load_treesitter()
    if treesitter_loaded then
        return
    end

    treesitter_loaded = true
    vim.pack.add({
        { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    }, { load = true })
    require('nvim-treesitter.configs').setup({
        ensure_installed = { 'diff', 'snakemake' },
    })
    require("config.treesitter_compat").setup()
end

local function toggle_context()
    load_treesitter()
    if not context_loaded then
        context_loaded = true
        vim.pack.add({
            { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },
        }, { load = true })
        require("treesitter-context").setup({
            enable = false,
            separator = nil,
            max_lines = 5,
            multiwindow = true,
            min_window_height = 15,
            multiline_threshold = 2,
        })
        vim.api.nvim_set_hl(0, "TreesitterContext", { link = "CursorLine" })
        vim.api.nvim_set_hl(0, "TreesitterContextBottom", { sp = "#b4befe" })
    end
    require("treesitter-context").toggle()
end

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
    group = vim.api.nvim_create_augroup("SetupTreesitter", { clear = true }),
    once = true,
    callback = load_treesitter,
})

vim.keymap.set("n", "<leader>tc", toggle_context, { desc = "Toggle Treesitter context" })
