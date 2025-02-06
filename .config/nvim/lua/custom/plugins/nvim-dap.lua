---@diagnostic disable: missing-parameter
return {
  {
    'mfussenegger/nvim-dap',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require 'custom.config.debugger'
    end,
  },
  {
    'rcarriga/nvim-dap-ui',
    dependencies = { 'mfussenegger/nvim-dap', 'theHamsta/nvim-dap-virtual-text', 'nvim-neotest/nvim-nio' },
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('nvim-dap-virtual-text').setup() -- optional
      require('noice').setup() -- optional
      require 'custom.config.dapui'
    end,
  },
  { -- python debugger
    'mfussenegger/nvim-dap-python',
    dependencies = {
      'mfussenegger/nvim-dap',
      'rcarriga/nvim-dap-ui',
    },
    ft = { 'python' },
    config = function()
      local path = '~/.local/share/nvim/mason/packages/debugpy/venv/bin/python'
      require('dap-python').setup(path)
    end,
  },
}
