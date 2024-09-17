return {
  'stevearc/overseer.nvim',
  cmd = {
    'OverseerQuickAction',
    'OverseerTaskAction',
    'OverseerToggle',
    'OverseerOpen',
  },
  keys = {
    { '<leader>or', '<cmd>OverseerRun<cr>', desc = 'Overseer run templates' },
    { '<leader>rl', '<cmd>OverseerRun<cr>', desc = 'Overseer run templates' },
    { '<leader>oR', '<cmd>OverseerRestartLast<cr>', desc = 'Overseer restart last command' },
    { '<leader>rr', '<cmd>OverseerRestartLast<cr>', desc = 'Overseer restart last command' },
    { '<leader>ot', '<cmd>OverseerToggle<cr>', desc = 'Overseer toggle task list' },
    { '<leader>rt', '<cmd>OverseerToggle<cr>', desc = 'Overseer toggle task list' },
    { '<leader>oa', '<cmd>OverseerQuickAction<cr>', desc = 'Overseer quick action list' },
    { '<leader>ra', '<cmd>OverseerToggle<cr>', desc = 'Overseer toggle task list' },
  },
  config = function()
    require 'custom.config.overseer'
  end,
}
