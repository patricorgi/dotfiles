return {
  'stevearc/overseer.nvim',
  event = 'VeryLazy',
  config = function()
    require 'custom.config.overseer'
  end,
}
