return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  event = 'VeryLazy',
  config = function()
    require 'custom.config.treesitter'
  end,
}
