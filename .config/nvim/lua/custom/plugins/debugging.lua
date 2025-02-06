local palette = require('catppuccin.palettes').get_palette 'mocha'
return {
  {
    'mfussenegger/nvim-dap',
    ft = { 'cpp', 'python' },
    dependencies = {
      'theHamsta/nvim-dap-virtual-text',
    },
    config = function()
      require 'custom.config.debugging'
    end,
  },
  {
    'rcarriga/nvim-dap-ui',
    dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' },
    config = function()
      local dap, dapui = require 'dap', require 'dapui'
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
      dapui.setup {
        layouts = {
          {
            position = 'left',
            size = 0.4,
            elements = {
              { id = 'stacks', size = 0.25 },
              { id = 'scopes', size = 0.25 },
              { id = 'breakpoints', size = 0.25 },
              { id = 'watches', size = 0.25 },
            },
          },
          {
            position = 'bottom',
            size = 0.2,
            elements = {
              { id = 'repl', size = 0.3 },
              { id = 'console', size = 0.7 },
            },
          },
        },
      }
    end,
  },
  {
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
