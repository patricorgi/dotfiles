return {
  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      {
        'stevearc/aerial.nvim',
        event = 'VeryLazy',
        opts = {},
      },
      'nvim-lua/plenary.nvim',
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
}
