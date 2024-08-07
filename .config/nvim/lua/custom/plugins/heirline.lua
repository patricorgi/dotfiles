return {
  'rebelot/heirline.nvim',
  event = 'VeryLazy',
  config = function()
    require('heirline').setup {
      statusline = require 'custom.config.heirline.statusline',
      tabline = require 'custom.config.heirline.tabline',
    }
  end,
}
