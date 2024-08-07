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
}
