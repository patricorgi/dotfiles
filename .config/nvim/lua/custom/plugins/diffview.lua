return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
  keys = {
    { '<leader>co', '<cmd>DiffviewOpen<cr>', desc = 'DiffView Open' },
    { '<leader>cc', '<cmd>DiffviewClose<cr>', desc = 'DiffView Close' },
    { '<leader>ch', '<cmd>DiffviewFileHistory %<cr>', desc = 'DiffView History' },
  },
  config = function()
    require 'custom.config.diffview'
  end,
}
