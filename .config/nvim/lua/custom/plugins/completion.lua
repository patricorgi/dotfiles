return {
  'saghen/blink.cmp',
  build = 'cargo build --release',
  dependencies = {
    'L3MON4D3/LuaSnip',
    version = 'v2.*',
    event = 'VeryLazy',
    config = function()
      require('luasnip.loaders.from_lua').load {
        paths = { '~/.config/nvim/lua/snippets' },
      }
      require('luasnip.loaders.from_vscode').lazy_load()
    end,
  },
  config = function()
    require 'custom.config.completion'
  end,
}
