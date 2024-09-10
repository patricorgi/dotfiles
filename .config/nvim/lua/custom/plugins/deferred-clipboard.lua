return {
  'EtiamNullam/deferred-clipboard.nvim',
  config = function()
    require('deferred-clipboard').setup {
      lazy = true,
      fallback = 'unnamedplus', -- or your preferred setting for clipboard
    }
  end,
}
