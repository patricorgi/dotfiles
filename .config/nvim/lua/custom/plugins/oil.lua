return {
  {
    'stevearc/oil.nvim',
    keys = {
      '-',
    },
    lazy = false,
    dependencies = { { 'nvim-tree/nvim-web-devicons', event = 'VeryLazy' } },
    config = function()
      require "custom.config.oil"
    end,
  },
}
