local custom_utils = require 'custom.utils'
return {
  'epwalsh/obsidian.nvim',
  enabled = custom_utils.is_mac(),
  version = '*', -- recommended, use latest release instead of latest commit
  lazy = true,
  event = {
    'BufReadPre ' .. vim.fn.expand '~' .. '/Documents/Obsidian Vault/*.md',
    'BufNewFile ' .. vim.fn.expand '~' .. '/Documents/Obsidian Vault/*.md',
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  config = function()
    require 'custom.config.obsidian'
  end,
}
