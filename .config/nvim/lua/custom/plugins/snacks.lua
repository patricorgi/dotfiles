---@diagnostic disable: undefined-global
return {
  'folke/snacks.nvim',
  lazy = false,
  config = function()
    require 'custom.config.snacks'
  end,
  keys = {
    {
      '<leader>gg',
      function()
        Snacks.lazygit { cwd = Snacks.git.get_root() }
      end,
      desc = 'Lazygit current buffer',
    },
    {
      '<leader>c',
      function()
        Snacks.bufdelete()
      end,
      desc = 'Delete Buffer',
    },
    {
      '<leader>bc',
      function()
        Snacks.bufdelete.other()
      end,
      desc = 'Delete Other Buffers',
    },
    {
      '<leader>n',
      function()
        Snacks.notifier.show_history()
      end,
      desc = 'Notification History',
    },
    {
      '<leader>gb',
      function()
        Snacks.git.blame_line()
      end,
      desc = 'Git Blame Line',
    },
  },
}
