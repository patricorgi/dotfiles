return {
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'stevearc/aerial.nvim',
        event = 'VeryLazy',
        opts = {},
        specs = {
          {
            'nvim-telescope/telescope.nvim',
            opts = function()
              require('telescope').load_extension 'aerial'
            end,
          },
        },
      },
      {
        'nvim-telescope/telescope-live-grep-args.nvim',
        keys = { '<leader>fw' },
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
