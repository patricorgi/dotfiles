local custom_utils = require 'custom.utils'
return {
  'keaising/im-select.nvim',
  enabled = function()
    return vim.fn.executable 'macism' == 1
  end,
  config = function()
    require('im_select').setup {}
  end,
}
