local custom_utils = require 'custom.utils'
return {
  'Exafunction/codeium.vim',
  enabled = custom_utils.is_mac(),
  cmd = {
    'Codeium',
    'CodeiumEnable',
    'CodeiumDisable',
    'CodeiumToggle',
    'CodeiumAuto',
    'CodeiumManual',
  },
  event = 'BufEnter',
  config = function()
    vim.keymap.set('n', '<Leader>;', '<Cmd>CodeiumToggle<CR>', { noremap = true, desc = 'Toggle Codeium active' })
    vim.keymap.set('i', '<C-g>', function()
      return vim.fn['codeium#Accept']()
    end, { expr = true })
    vim.keymap.set('i', '<C-;>', function()
      return vim.fn['codeium#CycleCompletions'](1)
    end, { expr = true })
    vim.keymap.set('i', '<C-,>', function()
      return vim.fn['codeium#CycleCompletions'](-1)
    end, { expr = true })
    vim.keymap.set('i', '<C-x>', function()
      return vim.fn['codeium#Clear']()
    end, { expr = true })
  end,
}
