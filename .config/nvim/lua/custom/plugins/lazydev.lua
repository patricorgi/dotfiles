return {
  {
    'folke/lazydev.nvim',
    enabled = false,
    dependencies = { 'Bilal2453/luvit-meta', lazy = true },
    ft = 'lua',
    opts = {
      library = {
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },
}
