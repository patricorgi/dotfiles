local custom_utils = require 'custom.utils'
return {
  {
    'vhyrro/luarocks.nvim',
    enabled = custom_utils.is_mac(),
    priority = 1001, -- this plugin needs to run before anything else
    opts = {
      rocks = { 'magick' },
    },
  },
  {
    '3rd/image.nvim',
    enabled = custom_utils.is_mac(),
    dependencies = { 'luarocks.nvim' },
    opts = {},
  },
}
