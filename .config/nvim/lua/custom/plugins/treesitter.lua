return {
  'patricorgi/nvim-treesitter',
  build = ':TSUpdate',
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    require 'custom.config.treesitter'
  end,
}
