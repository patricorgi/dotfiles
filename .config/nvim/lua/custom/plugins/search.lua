return {
  'FabianWirth/search.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-telescope/telescope.nvim' },
  config = function()
    require 'custom.config.search'
  end,
}
