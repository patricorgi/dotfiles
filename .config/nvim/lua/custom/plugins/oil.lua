return {
  {
    'stevearc/oil.nvim',
    keys = {
      '-',
    },
    lazy = false,
    dependencies = { { 'nvim-tree/nvim-web-devicons', event = 'VeryLazy' } },
    config = function()
      require('oil').setup {
        default_file_explorer = true,
        columns = { 'icon', 'mtime' },
        keymaps = {
          ['<C-h>'] = false,
          ['<C-l>'] = false,
          ['<C-k>'] = false,
          ['<C-j>'] = false,
          ['<C-r>'] = 'actions.refresh',
          ['\\'] = {'actions.select', opts = {horizontal = true}},
          ['|'] = {'actions.select', opts = {vertical = true}},
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
