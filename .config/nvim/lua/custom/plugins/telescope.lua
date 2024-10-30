return {
  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      {
        'stevearc/aerial.nvim',
        opts = {},
        dependencies = {
          'nvim-tree/nvim-web-devicons',
        },
      },
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      {
        'nvim-telescope/telescope-live-grep-args.nvim',
        keys = {
          '<leader>fw',
        },
        specs = {
          {
            'nvim-telescope/telescope.nvim',
            opts = function()
              require('telescope').load_extension 'live_grep_args'
            end,
          },
        },
      },
    },
    config = function()
      require 'custom.config.telescope'
    end,
  },
  {
    'FabianWirth/search.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    config = function()
      require 'custom.config.search'
    end,
  },
}
