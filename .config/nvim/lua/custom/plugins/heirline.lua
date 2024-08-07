return {
  'rebelot/heirline.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    vim.opt.cmdheight = 0
    require('heirline').setup {
      statusline = require 'custom.config.heirline.statusline',
      tabline = require 'custom.config.heirline.tabline',
    }
  end,
}
