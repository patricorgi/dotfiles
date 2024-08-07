return {
  'sindrets/diffview.nvim',
  event = 'VeryLazy',
  cmd = { 'DiffviewOpen' },
  keys = {
    { '<leader>do', '<cmd>DiffviewOpen<cr>', desc = 'DiffView Open' },
    { '<leader>dc', '<cmd>DiffviewClose<cr>', desc = 'DiffView Close' },
    { '<leader>dh', '<cmd>DiffviewFileHistory %<cr>', desc = 'DiffView History' },
  },
  specs = {
    {
      'NeogitOrg/neogit',
      optional = true,
      opts = { integrations = { diffview = true } },
    },
  },
  config = function()
    require 'custom.config.diffview'
  end,
}
