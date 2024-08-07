vim.api.nvim_create_autocmd('FileType', {
  pattern = 'OverseerList',
  callback = function()
    vim.opt_local.winfixbuf = true
  end,
})
local workdir = os.getenv 'WORKDIR'
local overseer = require 'overseer'
vim.api.nvim_create_user_command('OverseerRestartLast', function()
  local tasks = overseer.list_tasks { recent_first = true }
  if vim.tbl_isempty(tasks) then
    vim.notify('No tasks found', vim.log.levels.WARN)
  else
    overseer.run_action(tasks[1], 'restart')
  end
end, {})
vim.api.nvim_create_augroup('PreventQuitWithRunningTasks', { clear = true })
vim.api.nvim_create_autocmd('QuitPre', {
  group = 'PreventQuitWithRunningTasks',
  callback = function()
    local tasks = overseer.list_tasks { status = overseer.STATUS.RUNNING }
    if not vim.tbl_isempty(tasks) then
      print 'Cannot quit while tasks are running!'
      return false -- Cancel the quit command
    end
  end,
})

vim.keymap.set('n', '<Leader>rr', '<cmd>OverseerRun<cr>', { desc = 'Overseer run templates' })
vim.keymap.set('n', '<Leader>rt', '<cmd>OverseerToggle<cr>', { desc = 'Overseer toggle task list' })
vim.keymap.set('n', '<Leader>ra', '<cmd>OverseerQuickAction<cr>', { desc = 'Overseer quick action list' })
overseer.setup {
  dap = false,
  strategy = 'terminal',
  templates = {
    'shell',
    'make',
    'condor',
    'python',
    'user.grun_option',
    'user.run_script',
  },
  template_timeout = 3000,
  task_list = {
    direction = 'right',
    bindings = {
      ['?'] = 'ShowHelp',
      ['g?'] = 'ShowHelp',
      ['<CR>'] = 'RunAction',
      ['e'] = 'Edit',
      ['o'] = false,
      ['v'] = 'OpenVsplit',
      ['s'] = 'OpenSplit',
      ['f'] = 'OpenFloat',
      ['<C-q>'] = 'OpenQuickFix',
      ['p'] = 'TogglePreview',
      ['+'] = 'IncreaseDetail',
      ['_'] = 'DecreaseDetail',
      ['='] = 'IncreaseAllDetail',
      ['-'] = 'DecreaseAllDetail',
      ['['] = 'DecreaseWidth',
      [']'] = 'IncreaseWidth',
      ['k'] = 'PrevTask',
      ['j'] = 'NextTask',
      ['t'] = '<CMD>OverseerQuickAction open tab<CR>',
      ['<C-u>'] = false,
      ['<C-d>'] = false,
      ['<C-h>'] = false,
      ['<C-j>'] = false,
      ['<C-k>'] = false,
      ['<C-l>'] = false,
      ['q'] = 'Close',
    },
  },
}
overseer.add_template_hook({
  module = '^make$',
}, function(task_defn, util)
  util.add_component(task_defn, 'task_list_on_start')
  util.add_component(task_defn, { 'on_output_write_file', filename = task_defn.cmd[1] .. '.log' })
  util.add_component(task_defn, { 'on_output_quickfix', open_on_exit = 'failure' })
  util.add_component(task_defn, 'on_complete_notify')
  util.add_component(task_defn, { 'display_duration', detail_level = 1 })
  util.remove_component(task_defn, 'on_output_summarize')
end)

-- custom tasks
overseer.register_template {
  name = 'booleUT.qmt',
  priority = 0,
  builder = function()
    return {
      cmd = 'make',
      args = {
        'Boole',
        '&&',
        'utils/run-env',
        'Boole',
        'gaudirun.py',
        'Boole/Digi/Boole/tests/qmtest/boole.qms/boole-UT.qmt',
      },
      name = 'booleUT.qmt',
      cwd = vim.fn.getcwd(),
      components = {
        'task_list_on_start',
        'on_complete_notify',
        'display_duration',
        'on_exit_set_status',
      },
    }
  end,
  condition = {
    callback = function()
      local cwd = vim.fn.expand '%:p'
      local result = string.find(cwd, workdir .. '/stack-master/Boole', 1, true)
      if result then
        return true
      end
      return false
    end,
  },
}
