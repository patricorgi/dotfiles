local custom_utils = require 'custom.utils'
local toggle_overseer = function()
  vim.cmd 'OverseerToggle'
  custom_utils.func_on_window('dapui_stacks', function()
    require('dapui').open { reset = true }
  end)
end
return {
  'christoomey/vim-tmux-navigator',
  cmd = {
    'TmuxNavigateLeft',
    'TmuxNavigateDown',
    'TmuxNavigateUp',
    'TmuxNavigateRight',
    'TmuxNavigatePrevious',
    'TmuxNavigatorProcessList',
  },
  keys = {
    { '<C-h>', '<cmd><C-U>TmuxNavigateLeft<cr>' },
    { '<C-j>', '<cmd><C-U>TmuxNavigateDown<cr>' },
    { '<C-k>', '<cmd><C-U>TmuxNavigateUp<cr>' },
    { '<C-l>', '<cmd><C-U>TmuxNavigateRight<cr>' },
  },
  config = function ()
    vim.keymap.set('n', '<C-\\>', toggle_overseer, { desc = 'Overseer toggle task list' })
  end
}
