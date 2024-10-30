return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
  keys = {
    { '<leader>do', '<cmd>DiffviewOpen<cr>', desc = 'DiffView Open' },
    { '<leader>dc', '<cmd>DiffviewClose<cr>', desc = 'DiffView Close' },
    { '<leader>dh', '<cmd>DiffviewFileHistory %<cr>', desc = 'DiffView History' },
  },
  config = function()
    require 'custom.config.diffview'
  end,
}
