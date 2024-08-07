return {
  'NStefan002/screenkey.nvim',
  cmds = {
    'Screenkey',
  },
  keys = {
    { '<leader>ts', '<cmd>Screenkey<cr>', desc = 'Toggle ScreenKey' },
  },
  event = 'VeryLazy',
  version = '*', -- or branch = "dev", to use the latest commit
}
