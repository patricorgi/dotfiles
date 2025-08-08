local constants = require "overseer.constants"
local log = require "overseer.log"
local overseer = require "overseer"
local TAG = constants.TAG

---@type overseer.TemplateFileDefinition
return {
  name = "condor_make",
  autostart = false,
  priority = 100,
  tags = { TAG.BUILD },
  params = {
    target = { optional = false, type = "string" },
    args = { optional = true, type = "list", delimiter = " " },
    cwd = {
      optional = false,
      default = vim.fs.dirname(
        vim.fs.find("Makefile", { upward = true, type = "file", path = vim.fn.expand "%:p:h" })[1]
      ),
    },
  },
  builder = function(params)
    return {
      name = "make " .. params.target,
      cmd = { "/home/hwu/dotfiles/scripts/condor_make.sh", params.target },
      args = params.args,
      cwd = params.cwd,
      -- components = { "task_list_on_start", "hsplit_on_start",  "default" },
      components = { "task_list_on_start", "default" },
    }
  end,
  condition = {
    callback = function() return vim.fn.executable "condor_make" == 1 end,
  },
}
