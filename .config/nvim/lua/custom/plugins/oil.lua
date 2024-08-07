return {
  'stevearc/oil.nvim',
  lazy = false,
  dependencies = { 'echasnovski/mini.nvim' },
  config = function()
    require 'custom.config.oil'
  end,
}
