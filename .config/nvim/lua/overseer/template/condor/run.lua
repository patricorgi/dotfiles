-- /home/stevearc/.config/nvim/lua/overseer/template/user/run_script.lua
return {
  name = "condor run",
  params = {
    cmd = { optional = false },
    cwd = { optional = false, default = vim.fn.expand "%:p:h" },
  },
  builder = function(params)
    return {
      cmd = { "/home/hwu/dotfiles/scripts/condor_run.sh", params.cmd },
      cwd = params.cwd,
      components = { "task_list_on_start", "hsplit_on_start", "default" },
    }
  end,
  condition = {
    callback = function() return vim.fn.executable "condor_make" == 1 end,
    filetype = { "sh", "python", "go" },
  },
}
