local constants = require("overseer.constants")
local log = require("overseer.log")
local overseer = require("overseer")
local TAG = constants.TAG

local make_targets = [[
(rule_definition name: (identifier) @name)
]]

---@type overseer.TemplateFileDefinition
local tmpl = {
  name = "snakemake",
  priority = 60,
  tags = { TAG.BUILD },
  autostart = false,
  params = {
    args = { optional = false, type = "list", delimiter = " " },
    cpus = { optional = true, type = 'integer' },
    cwd = { optional = true },
    rule = { optional = true },
  },
  builder = function(params)
    return {
      name = string.format("󱔎 %s", params.rule),
      cmd = { "snakemake" },
      args = params.args,
      cwd = params.cwd,
      components = {
        "display_duration",
        "on_exit_set_status",
        "on_complete_notify",
      },
    }
  end,
}

local function ts_parse_make_targets(parser, bufnr, cwd)
  local query
  if vim.treesitter.query.parse then
    -- Neovim 0.9
    query = vim.treesitter.query.parse("snakemake", make_targets)
  else
    ---@diagnostic disable-next-line: undefined-field
    query = vim.treesitter.parse_query("snakemake", make_targets)
  end
  local root = parser:parse()[1]:root()
  pcall(vim.tbl_add_reverse_lookup, query.captures)
  local targets = {}
  local default_target
  ---@diagnostic disable-next-line: missing-parameter
  for _, match in query:iter_matches(root, bufnr) do
    ---@diagnostic disable-next-line: undefined-field
    local name = vim.treesitter.get_node_text(match[query.captures.name], bufnr)
    targets[name] = true
  end

  local ret = {}
  for k in pairs(targets) do
    local override = { name = string.format("snakemake %s", k) }
    if k == default_target then
      override.priority = 55
    end
    table.insert(ret,
      overseer.wrap_template(tmpl, override, { args = { "-p", "-c", "1", '--cores', '2', k }, cwd = cwd, rule = k }))
  end
  return ret
end

local function parse_make_output(cwd, ret, cb)
  local jid = vim.fn.jobstart({ "snakemake", "-rRpq" }, {
    cwd = cwd,
    stdout_buffered = true,
    on_stdout = vim.schedule_wrap(function(j, output)
      local parsing = false
      local prev_line = ""
      for _, line in ipairs(output) do
        if line:find("# Files") == 1 then
          parsing = true
        elseif line:find("# Finished Make") == 1 then
          break
        elseif parsing then
          if line:match("^[^%.#%s]") and prev_line:find("# Not a target") ~= 1 then
            local idx = line:find(":")
            if idx then
              local target = line:sub(1, idx - 1)
              local override = { name = string.format("snakemake %s", target) }
              table.insert(
                ret,
                overseer.wrap_template(tmpl, override, { args = { target }, cwd = cwd })
              )
            end
          end
        end
        prev_line = line
      end

      cb(ret)
    end),
  })
  if jid == 0 then
    log:error("Passed invalid arguments to 'snakemake'")
    cb(ret)
  elseif jid == -1 then
    log:error("'snakemake' is not executable")
    cb(ret)
  end
end

---@param opts overseer.SearchParams
---@return nil|string
local function get_makefile(opts)
  return vim.fs.find("Snakefile", { upward = true, type = "file", path = opts.dir })[1]
end

---@type overseer.TemplateFileProvider
local provider = {
  cache_key = function(opts)
    return get_makefile(opts)
  end,
  condition = {
    callback = function(opts)
      if vim.fn.executable("snakemake") == 0 then
        return false, 'Command "snakemake" not found'
      end
      if not get_makefile(opts) then
        return false, "No Snakefile found"
      end
      return true
    end,
  },
  generator = function(opts, cb)
    local makefile = assert(get_makefile(opts))
    local cwd = vim.fs.dirname(makefile)
    local bufnr = vim.fn.bufadd(makefile)
    local ret = { overseer.wrap_template(tmpl, nil, { cwd = cwd }) }
    local ok, parser =
        pcall(vim.treesitter.get_parser, bufnr, "snakemake")
    if ok then
      vim.list_extend(ret, ts_parse_make_targets(parser, bufnr, cwd))
      cb(ret)
    else
      parse_make_output(cwd, ret, cb)
    end
  end,
}
return provider
