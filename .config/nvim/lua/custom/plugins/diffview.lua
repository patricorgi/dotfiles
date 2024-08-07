return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
  keys = {
    { '<leader>Do', '<cmd>DiffviewOpen<cr>', desc = 'DiffView Open' },
    { '<leader>Dc', '<cmd>DiffviewClose<cr>', desc = 'DiffView Close' },
    { '<leader>Dh', '<cmd>DiffviewFileHistory %<cr>', desc = 'DiffView History' },
  },
  config = function()
    require 'custom.config.diffview'
  end,
}
