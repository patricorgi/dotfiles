return {
  'kdheepak/lazygit.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  event = 'User AstroFile',
  cmd = { 'LazyGit', 'LazyGitCurrentFile' },
  keys = {
    { '<leader>gg', '<cmd>LazyGitCurrentFile<CR>', desc = 'Open LazyGit' },
  },
  config = function()
    vim.g.lazygit_floating_window_scaling_factor = 1.0
  end,
}
