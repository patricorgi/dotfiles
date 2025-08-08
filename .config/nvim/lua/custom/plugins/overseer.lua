return {
  'stevearc/overseer.nvim',
  cmd = {
    'OverseerQuickAction',
    'OverseerTaskAction',
    'OverseerToggle',
    'OverseerOpen',
  },
  keys = {
    { '<leader>rl', '<cmd>OverseerRun<cr>', desc = 'Overseer run templates' },
    { '<leader>rr', '<cmd>OverseerRestartLast<cr>', desc = 'Overseer restart last command' },
    { '<leader>rt', '<cmd>OverseerToggle<cr>', desc = 'Overseer toggle task list' },
    { '<leader>ra', '<cmd>OverseerToggle<cr>', desc = 'Overseer toggle task list' },
  },
  config = function()
    require 'custom.config.overseer'
  end,
}
