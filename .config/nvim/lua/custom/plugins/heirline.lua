return {
  'rebelot/heirline.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  init = function()
    vim.keymap.set('n', '<leader>tt', function()
      vim.o.showtabline = vim.o.showtabline == 0 and 2 or 0
    end, { desc = 'Toggle tabline' })
  end,
  config = function()
    vim.opt.cmdheight = 0
    require('heirline').setup {
      statusline = require 'custom.config.heirline.statusline',
      -- tabline = require 'custom.config.heirline.tabline',
    }
  end,
}
