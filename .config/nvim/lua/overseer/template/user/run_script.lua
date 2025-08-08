return {
  name = 'run script',
  condition = {
    filetype = { 'sh', 'python' },
  },
  params = {
    args = { optional = true, type = 'list', delimiter = ' ' },
    cwd = { optional = false, type = 'enum', default = vim.fn.getcwd(), choices = { vim.fn.getcwd(), vim.fn.expand('%:p:h')} },
  },
  builder = function(params)
    local args = { vim.fn.expand '%:p' }
    if params.args then
      args = vim.list_extend(args, params.args)
    end
    return {
      name = vim.fn.expand '%:t',
      cmd = vim.bo.filetype == 'sh' and 'bash' or 'python3',
      args = args,
      cwd = params.cwd,
      components = {
        -- "task_list_on_start",
        'display_duration',
        'on_exit_set_status',
        'on_complete_notify',
      },
    }
  end,
}
