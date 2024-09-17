return {
  {
    'stevearc/oil.nvim',
    keys = {
      '-',
    },
    dependencies = { { 'nvim-tree/nvim-web-devicons', event = 'VeryLazy' } },
    config = function()
      require('oil').setup {
        columns = { 'icon' },
        keymaps = {
          ['<C-h>'] = false,
          ['<C-l>'] = false,
          ['<C-k>'] = false,
          ['<C-j>'] = false,
          ['-'] = 'actions.close',
          ['<BS>'] = 'actions.parent',
        },
        view_options = {
          show_hidden = true,
        },
      }

      -- Open parent directory in current window
      vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })

      -- Open parent directory in floating window
      vim.keymap.set('n', '<space>-', require('oil').toggle_float)
    end,
  },
}
