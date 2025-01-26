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
      elements = {
        {
          id = 'stacks',
          size = 0.25,
        },
        {
          id = 'scopes',
          size = 0.25,
        },
        {
          id = 'breakpoints',
          size = 0.25,
        },
        {
          id = 'watches',
          size = 0.25,
        },
      },
      position = 'left',
      size = 0.4,
    },
    {
      elements = { {
        id = 'repl',
        size = 0.3,
      }, {
        id = 'console',
        size = 0.7,
      } },
      position = 'bottom',
      size = 0.2,
    },
  },
}
-- set up dressing for vim.fn.input
require("dressing").setup()

---@diagnostic disable-next-line: missing-parameter
require('nvim-dap-virtual-text').setup()
vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = 'DAP: Toggle UI' })
vim.keymap.set('n', '<leader>ds', dap.continue, { desc = 'DAP: Start/Continue' })
vim.keymap.set('n', '<F1>', dap.continue, { desc = 'DAP: Start/Continue' })
vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'DAP: Breakpoint' })
vim.keymap.set('n', '<leader>dB', function()
  local condition_str = vim.fn.input 'Condition: '
  dap.set_breakpoint(condition_str)
end, { desc = 'DAP: Conditional Breakpoint' })
vim.keymap.set('n', '<leader>dD', dap.clear_breakpoints, { desc = 'DAP: Clear Breakpoints' })
vim.keymap.set('n', '<leader>di', dap.step_into, { desc = 'DAP: Step into' })
vim.keymap.set('n', '<F2>', dap.step_into, { desc = 'DAP: Step into' })
vim.keymap.set('n', '<leader>do', dap.step_over, { desc = 'DAP: Step over' })
vim.keymap.set('n', '<F3>', dap.step_over, { desc = 'DAP: Step over' })
vim.keymap.set('n', '<leader>dO', dap.step_out, { desc = 'DAP: Step out' })
vim.keymap.set('n', '<F4>', dap.step_out, { desc = 'DAP: Step out' })
vim.keymap.set('n', '<F5>', dap.step_back, { desc = 'DAP: Step back' })
vim.keymap.set('n', '<leader>dq', dap.close, { desc = 'DAP: Close session' })
vim.keymap.set('n', '<leader>dQ', dap.terminate, { desc = 'DAP: Terminate session' })
vim.keymap.set('n', '<F12>', dap.terminate, { desc = 'DAP: Terminate session' })
vim.keymap.set('n', '<leader>dr', dap.restart_frame, { desc = 'DAP: Restart' })
vim.keymap.set('n', '<leader>dR', dap.repl.toggle, { desc = 'DAP: Toggle REPL' })
vim.keymap.set('n', '<leader>dh', require('dap.ui.widgets').hover, { desc = 'DAP: Hover' })
vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DapBreakpoint', linehl = '', numhl = 'DapBreakpoint' })
vim.fn.sign_define(
  'DapBreakpointCondition',
  { text = '', texthl = 'DapBreakpointCondition', linehl = 'DapBreakpointCondition', numhl = 'DapBreakpointCondition' }
)
vim.fn.sign_define('DapStopped', { text = '', texthl = 'DapStopped', linehl = 'DapStopped', numhl = 'DapStopped' })

local cpptools_path = vim.fn.getenv 'VSCPPTOOLS'
if not (cpptools_path == nil or cpptools_path == '') then
  dap.adapters.cppdbg = {
    id = 'cppdbg',
    type = 'executable',
    command = cpptools_path,
    options = {
      detached = false,
    },
  }
  dap.adapters.gdb = {
    type = 'executable',
    command = 'gdb',
    args = { '--interpreter=dap', '--eval-command', 'set print pretty on' },
  }
  dap.configurations.qmt = {
    {
      MIMode = 'gdb',
      args = {
        '${workspaceFolder}/Gaudi/Gaudi/scripts/gaudirun.py',
        '${file}',
      },
      cwd = '${fileDirname}',
      externalConsole = false,
      miDebuggerPath = function()
        local project = vim.fn.input('Project name: ', 'Moore')
        return '${workspaceFolder}/' .. project .. '/gdb'
      end,
      name = 'GDB: gaudirun.py',
      program = '/cvmfs/lhcb.cern.ch/lib/lcg/releases/Python/3.9.12-9a1bc/x86_64-el9-gcc13-dbg/bin/python3',
      request = 'launch',
      setupCommands = {
        {
          description = 'Enable pretty-printing for gdb',
          ignoreFailures = true,
          text = '-enable-pretty-printing',
        },
      },
      type = 'cppdbg',
    },
    {
      MIMode = 'gdb',
      args = {
        'qmtexec',
        '${file}',
      },
      cwd = '${fileDirname}',
      externalConsole = false,
      miDebuggerPath = '${workspaceFolder}/Gaudi/gdb',
      name = 'GDB: qmtexec',
      program = function()
        local project = vim.fn.input('Project name: ', 'Moore')
        return '${workspaceFolder}/' .. project .. '/run'
      end,
      request = 'launch',
      setupCommands = {
        {
          description = 'Enable pretty-printing for gdb',
          ignoreFailures = true,
          text = '-enable-pretty-printing',
        },
      },
      type = 'cppdbg',
    },
    {
      MIMode = 'gdb',
      miDebuggerPath = '${workspaceFolder}/Gaudi/Gaudi/gdb',
      name = 'GDB: attach',
      processId = '${command:pickProcess}',
      program = '/cvmfs/lhcb.cern.ch/lib/lcg/releases/Python/3.9.12-9a1bc/x86_64-el9-gcc13-opt/bin/python',
      request = 'attach',
      setupCommands = {
        {
          description = 'Enable pretty-printing for gdb',
          ignoreFailures = true,
          text = '-enable-pretty-printing',
        },
      },
      type = 'cppdbg',
    },
  }
  dap.configurations.python = dap.configurations.qmt
  dap.configurations.cpp = {
    {
      name = 'Launch',
      type = 'cppdbg',
      MIMode = 'gdb',
      request = 'launch',
      miDebuggerPath = '/usr/bin/gdb',
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      cwd = '${workspaceFolder}',
      setupCommands = {
        {
          description = 'Enable pretty-printing for gdb',
          ignoreFailures = true,
          text = '-enable-pretty-printing',
        },
      },
      stopAtBeginningOfMainSubprogram = false,
    },
    {
      name = 'Select and attach to process',
      type = 'cppdbg',
      request = 'attach',
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      pid = function()
        local name = vim.fn.input 'Executable name (filter): '
        return require('dap.utils').pick_process { filter = name }
      end,
      cwd = '${workspaceFolder}',
    },
    {
      name = 'Attach to gdbserver :1234',
      type = 'gdb',
      request = 'attach',
      target = 'localhost:1234',
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      cwd = '${workspaceFolder}',
    },
  }
end
