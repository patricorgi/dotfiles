return {
  'nvim-neo-tree/neo-tree.nvim',
  event = 'VeryLazy',
  keys = {
    { 'B', '<cmd>Neotree toggle<cr>', desc = 'Toggle Neotree' },
    { '<leader>e', '<cmd>Neotree toggle<cr>', desc = 'Toggle Neotree' },
    { '<leader>nr', '<cmd>Neotree reveal<cr>', desc = 'Reveal in Neotree' },
  },
  dependencies = {
    'akinsho/toggleterm.nvim',
  },
  config = function()
    require 'custom.config.neo-tree'
  end,
}
