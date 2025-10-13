local dap = require("dap")

-- NOTE: configure adapters
dap.adapters.codelldb = {
	type = "executable",
	command = "codelldb", -- or if not in $PATH: "/absolute/path/to/codelldb"
}
dap.adapters.cppdbg = {
	id = "cppdbg",
	type = "executable",
	command = "OpenDebugAD7", -- or if not in $PATH: "/absolute/path/to/OpenDebugAD7"
	options = { detached = false },
}
dap.adapters.gdb = {
	type = "executable",
	command = "gdb",
	args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
}

dap.adapters.cudagdb = {
	type = "executable",
	command = "cuda-gdb",
}

-- NOTE: filetype configurations
dap.configurations.cuda = {
	{
		name = "Launch (cuda-gdb)",
		type = "cudagdb",
		request = "launch",
		program = function()
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
	},
	{
		name = "Launch (gdb)",
		type = "cppdbg",
		MIMode = "gdb",
		request = "launch",
		miDebuggerPath = "/usr/bin/gdb",
		program = function()
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
		end,
		cwd = "${workspaceFolder}",
		setupCommands = {
			{
				description = "Enable pretty-printing for gdb",
				ignoreFailures = true,
				text = "-enable-pretty-printing",
			},
		},
		stopAtBeginningOfMainSubprogram = false,
	},
}
dap.configurations.cpp = dap.configurations.cpp or {}

vim.list_extend(dap.configurations.cpp, {
	{
		name = "Launch (codelldb)",
		type = "codelldb",
		request = "launch",
		program = function()
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
	},
	{
		name = "Launch (gdb)",
		type = "cppdbg",
		MIMode = "gdb",
		request = "launch",
		miDebuggerPath = "/usr/bin/gdb",
		program = function()
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
		end,
		cwd = "${workspaceFolder}",
		setupCommands = {
			{
				description = "Enable pretty-printing for gdb",
				ignoreFailures = true,
				text = "-enable-pretty-printing",
			},
		},
		stopAtBeginningOfMainSubprogram = false,
	},
	{
		name = "Select and attach to process",
		type = "cppdbg",
		request = "attach",
		program = function()
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
		end,
		pid = function()
			local name = vim.fn.input("Executable name (filter): ")
			return require("dap.utils").pick_process({ filter = name })
		end,
		cwd = "${workspaceFolder}",
	},
})

dap.configurations.python = dap.configurations.python or {}
vim.list_extend(dap.configurations.python, {
	{
		type = "python",
		request = "launch",
		name = "file:args (cwd)",
		program = "${file}",
		args = function()
			local args_string = vim.fn.input("Arguments: ")
			local utils = require("dap.utils")
			if utils.splitstr and vim.fn.has("nvim-0.10") == 1 then
				return utils.splitstr(args_string)
			end
			return vim.split(args_string, " +")
		end,
		console = "integratedTerminal",
		cwd = vim.fn.getcwd(),
	},
	{
		MIMode = "gdb",
		args = {
			"${workspaceFolder}/Gaudi/Gaudi/scripts/gaudirun.py",
			"${file}",
		},
		cwd = "${fileDirname}",
		externalConsole = false,
		miDebuggerPath = "${workspaceFolder}/Moore/gdb",
		name = "GDB: gaudirun.py (Moore)",
		program = function()
			local result = vim.system({ "utils/run-env", "Gaudi", "which", "python3" }, { text = true }):wait()
			return vim.trim(result.stdout)
		end,
		request = "launch",
		setupCommands = {
			{
				description = "Enable pretty-printing for gdb",
				ignoreFailures = true,
				text = "-enable-pretty-printing",
			},
		},
		type = "cppdbg",
		preLaunchTask = "make fast/Rec",
	},
	{
		MIMode = "gdb",
		args = {
			"${workspaceFolder}/Gaudi/Gaudi/scripts/gaudirun.py",
			"${file}",
		},
		cwd = "${fileDirname}",
		externalConsole = false,
		-- miDebuggerPath = '${workspaceFolder}/${input:lhcbProject}/gdb',
		miDebuggerPath = function()
			local project = vim.fn.input("Project name: ", "Moore")
			return "${workspaceFolder}/" .. project .. "/gdb"
		end,
		name = "GDB: gaudirun.py",
		program = function()
			local result = vim.system({ "utils/run-env", "Gaudi", "which", "python3" }, { text = true }):wait()
			return vim.trim(result.stdout)
		end,
		request = "launch",
		setupCommands = {
			{
				description = "Enable pretty-printing for gdb",
				ignoreFailures = true,
				text = "-enable-pretty-printing",
			},
		},
		type = "cppdbg",
	},
	{
		MIMode = "gdb",
		args = {
			"qmtexec",
			"${file}",
		},
		cwd = "${fileDirname}",
		externalConsole = false,
		miDebuggerPath = "${workspaceFolder}/Gaudi/gdb",
		name = "GDB: qmtexec",
		program = function()
			local project = vim.fn.input("Project name: ", "Moore")
			return "${workspaceFolder}/" .. project .. "/run"
		end,
		request = "launch",
		setupCommands = {
			{
				description = "Enable pretty-printing for gdb",
				ignoreFailures = true,
				text = "-enable-pretty-printing",
			},
		},
		type = "cppdbg",
	},
	{
		MIMode = "gdb",
		miDebuggerPath = "${workspaceFolder}/Gaudi/Gaudi/gdb",
		name = "GDB: attach",
		processId = "${command:pickProcess}",
		program = "/cvmfs/lhcb.cern.ch/lib/lcg/releases/Python/3.9.12-9a1bc/x86_64-el9-gcc13-opt/bin/python",
		request = "attach",
		setupCommands = {
			{
				description = "Enable pretty-printing for gdb",
				ignoreFailures = true,
				text = "-enable-pretty-printing",
			},
		},
		type = "cppdbg",
	},
})
dap.configurations.qmt = dap.configurations.python

require("nvim-dap-virtual-text").setup()
local ok, noice = pcall(require, "noice")
if ok then
	noice.setup()
end

local custom_utils = require 'config.utils'
-- UI responsiveness
local dap, dapui = require 'dap', require 'dapui'
dap.listeners.before.attach.dapui_config = function()
  dapui.open({reset = true})
 custom_utils.reset_overseerlist_width()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open({reset = true})
 custom_utils.reset_overseerlist_width()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end

-- customize UI layout
dapui.setup {
  expand_lines = false,
  layouts = {
    {
      position = 'left',
      size = 0.2,
      elements = {
        { id = 'stacks', size = 0.2 },
        { id = 'scopes', size = 0.5 },
        { id = 'breakpoints', size = 0.15 },
        { id = 'watches', size = 0.15 },
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

-- Custom breakpoint icons
vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DapBreakpoint', linehl = '', numhl = 'DapBreakpoint' })
vim.fn.sign_define(
  'DapBreakpointCondition',
  { text = '', texthl = 'DapBreakpointCondition', linehl = 'DapBreakpointCondition', numhl = 'DapBreakpointCondition' }
)
vim.fn.sign_define('DapStopped', { text = '', texthl = 'DapStopped', linehl = 'DapStopped', numhl = 'DapStopped' })

-- keymaps
vim.keymap.set('n', '<leader>du', function ()
 dapui.toggle({reset = true})
 custom_utils.reset_overseerlist_width()
end, { desc = 'DAP: Toggle UI' })
vim.keymap.set('n', '<F1>', function ()
 dapui.toggle({reset = true})
 custom_utils.reset_overseerlist_width()
end, { desc = 'DAP: Toggle UI' })
vim.keymap.set('n', '<leader>ds', dap.continue, { desc = ' Start/Continue' })
vim.keymap.set('n', '<F2>', dap.continue, { desc = ' Start/Continue' })
vim.keymap.set('n', '<leader>di', dap.step_into, { desc = ' Step into' })
vim.keymap.set('n', '<F3>', dap.step_into, { desc = ' Step into' })
vim.keymap.set('n', '<leader>do', dap.step_over, { desc = ' Step over' })
vim.keymap.set('n', '<F4>', dap.step_over, { desc = ' Step over' })
vim.keymap.set('n', '<leader>dO', dap.step_out, { desc = ' Step out' })
vim.keymap.set('n', '<F5>', dap.step_out, { desc = ' Step out' })
vim.keymap.set('n', '<leader>dq', dap.close, { desc = 'DAP: Close session' })
vim.keymap.set('n', '<leader>dr', dap.restart_frame, { desc = 'DAP: Restart frame' })
vim.keymap.set('n', '<F6>', dap.restart, { desc = 'DAP: Start over' })
vim.keymap.set('n', '<leader>dQ', dap.terminate, { desc = ' Terminate session' })
vim.keymap.set('n', '<F7>', dap.terminate, { desc = ' Terminate session' })

vim.keymap.set('n', '<leader>dc', dap.run_to_cursor, { desc = 'DAP: Run to Cursor' })
vim.keymap.set('n', '<leader>dR', dap.repl.toggle, { desc = 'DAP: Toggle REPL' })
vim.keymap.set('n', '<leader>dh', require('dap.ui.widgets').hover, { desc = 'DAP: Hover' })

vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'DAP: Breakpoint' })
vim.keymap.set('n', '<leader>dB', function()
  local input = vim.fn.input 'Condition for breakpoint:'
  dap.set_breakpoint(input)
end, { desc = 'DAP: Conditional Breakpoint' })
vim.keymap.set('n', '<leader>dD', dap.clear_breakpoints, { desc = 'DAP: Clear Breakpoints' })
