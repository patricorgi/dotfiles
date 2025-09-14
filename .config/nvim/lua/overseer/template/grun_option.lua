local overseer = require "overseer"
local workdir = os.getenv "WORKDIR"

---@type overseer.TemplateFileDefinition
local tmpl = {
  name = "Run option file",
  priority = 100,
  params = {
    stack = { optional = false, type = "opaque" },
    app = { optional = false, type = "enum", choices = { "Moore", "Alignment", "Gauss", "Boole" }, default = "Moore" },
    gaudiscript = {
      optional = true,
      type = "enum",
      choices = { "gaudiiter.py", "gaudisplititer.py" },
      default = "gaudiiter.py",
      desc = "gaudi script other than gaudirun.py",
    },
    extra_args = {
      optional = true,
      type = "list",
      delimiter = " ",
      desc = "gaudi(split)iter.py will need extra args",
    },
  },
  builder = function(params)
    local cmd = workdir .. "/" .. params.stack .. "/utils/run-env"
    local args = { params.app }
    local file = vim.fn.expand "%:p"
    if params.app == "Alignment" then
      table.insert(args, params.gaudiscript)
    else
      table.insert(args, "gaudirun.py")
    end
    if params.extra_args then
      for _, arg in ipairs(params.extra_args) do
        table.insert(args, arg)
      end
    end
    table.insert(args, file)
    return {
      name = vim.fn.expand "%:t",
      cwd = vim.fn.expand "%:p:h",
      autostart = false,
      cmd = cmd,
      args = args,
      components = {
        "task_list_on_start",
        "display_duration",
        "on_exit_set_status",
        { "open_output", on_start = "always", direction = "dock", focus = true },
        "on_complete_notify",
      },
    }
  end,
}

local function find_all_stacks()
  local file = io.popen(
    "find "
      .. workdir
      .. ' -maxdepth 3 -name "run-env" -type f | xargs dirname | xargs dirname | xargs -I{} basename {}'
  )
  local lines = {}
  if file then
    for line in file:lines() do
      table.insert(lines, line)
    end
    file:close()
  else
    print "Error: Unable to open the file"
  end
  return lines
end

---@type overseer.TemplateFileProvider
local provider = {
  condition = {
    callback = function()
      if vim.bo.filetype ~= "python" and vim.bo.filetype ~= "qmt" then return false end
      local cwd = vim.fn.getcwd()
      local result1 = string.find(cwd, workdir .. "/utOptions", 1, true)
      local result2 = string.find(cwd, workdir .. "/stack", 1, true)
      if result1 or result2 then return true end
      return false
    end,
  },
  generator = function(_, cb)
    local stacks = find_all_stacks()
    local ret = {}
    for _, stack in ipairs(stacks) do
      local override = { name = string.format("Run with %s", stack), autostart = false }
      table.insert(ret, overseer.wrap_template(tmpl, override, { stack = stack }))
    end
    cb(ret)
  end,
}
return provider
