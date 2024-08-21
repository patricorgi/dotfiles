return {
  'ray-x/lsp_signature.nvim',
  event = 'VeryLazy',
  main = 'lsp_signature',
  opts = {
    hint_enable = false, -- disable hints as it will crash in some terminal
  },
  specs = {
    {
      'folke/noice.nvim',
      optional = true,
      opts = {
        lsp = {
          signature = { enabled = false },
          hover = { enabled = false },
        },
      },
    },
  },
}
