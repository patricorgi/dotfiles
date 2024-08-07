return { -- Fuzzy Finder (files, lsp, etc)
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { -- If encountering errors, see telescope-fzf-native README for installation instructions
      'nvim-telescope/telescope-fzf-native.nvim',

      -- `build` is used to run some command when the plugin is installed/updated.
      -- This is only run then, not every time Neovim starts up.
      build = 'make',

      -- `cond` is a condition used to determine whether this plugin should be
      -- installed and loaded.
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    -- { 'nvim-telescope/telescope-ui-select.nvim' },

    -- Useful for getting pretty icons, but requires a Nerd Font.
    {
      'nvim-telescope/telescope-live-grep-args.nvim',
      event = 'VeryLazy',
      specs = {
        {
          'nvim-telescope/telescope.nvim',
          dependencies = { 'nvim-telescope/telescope-live-grep-args.nvim' },
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
}
