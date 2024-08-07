local dap = require 'dap'

-- NOTE: configure adapters
dap.adapters.codelldb = {
  type = 'executable',
  command = 'codelldb', -- or if not in $PATH: "/absolute/path/to/codelldb"
}
dap.adapters.cppdbg = {
  id = 'cppdbg',
  type = 'executable',
  command = 'OpenDebugAD7', -- or if not in $PATH: "/absolute/path/to/OpenDebugAD7"
  options = { detached = false },
}
dap.adapters.gdb = {
  type = 'executable',
  command = 'gdb',
  args = { '--interpreter=dap', '--eval-command', 'set print pretty on' },
}

-- NOTE: filetype configurations
dap.configurations.cpp = {
  {
    name = 'Launch (codelldb)',
    type = 'codelldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  },
  {
    name = 'Launch (gdb)',
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
}
dap.configurations.python = {
  {
    type = 'python',
    request = 'launch',
    name = 'file:args (cwd)',
    program = '${file}',
    args = function()
      local args_string = vim.fn.input 'Arguments: '
      local utils = require 'dap.utils'
      if utils.splitstr and vim.fn.has 'nvim-0.10' == 1 then
        return utils.splitstr(args_string)
      end
      return vim.split(args_string, ' +')
    end,
    console = 'integratedTerminal',
    cwd = vim.fn.getcwd(),
  },
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
dap.configurations.qmt = dap.configurations.python
