return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
  keys = {
    {
      '<leader>co',
      function()
        local view = require('diffview.lib').get_current_view()
        if view then
          vim.cmd [[DiffviewClose]]
        else
          vim.cmd [[DiffviewOpen]]
        end
      end,
      desc = 'DiffView Toggle',
    },
    {
      '<leader>ch',
      function()
        local view = require('diffview.lib').get_current_view()
        if view then
          vim.cmd [[DiffviewClose]]
        else
          vim.cmd [[DiffviewFileHistory %]]
        end
      end,
      desc = 'DiffView History',
    },
  },
  config = function()
    require 'custom.config.diffview'
  end,
}
