local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local entry_display = require 'telescope.pickers.entry_display'
local conf = require('telescope.config').values
local Terminal = require('toggleterm.terminal').Terminal

local setup_opts = {
  git_cmd = 'lazygit',
  terminal_id = 9,
}

-- Mention the pointer in the unception thing
local function open_git_tool(opts, selection)
  if selection == nil then
    selection = action_state.get_selected_entry().value -- picking the repo_name from the item received
  end
  local dir_name = vim.fn.substitute(vim.fn.getcwd(), '^.*/', '', '')
  local git_tool = Terminal:new {
    cmd = opts.git_cmd,
    close_on_exit = true,
    hidden = true,
    direction = 'float',
    count = opts.terminal_id,
  }

  if selection == dir_name then
    git_tool.dir = vim.fn.getcwd()
  else
    git_tool.dir = vim.fn.getcwd() .. '/' .. selection
  end
  git_tool:toggle()

  vim.cmd 'stopinsert'
  vim.cmd [[execute "normal i"]]
end

local function prepare_repos()
  local items = {}
  local script = [[
		for d in */; do
			case "$d" in
				"DDDB/" | "SIMCOND/" | "lhcb-conditions-database/" | "lcd-master/" | "lcd-master-hit-error/" | "lcd-sim10-run3-ideal/" | "GaussinoExtLibs/" | "Run2Support/" | "Geant4/" | "Gaudi/" | "Gaussino/" | "utils/" )
				continue
				;;
				*)
				if [ -d "$d.git" ] || [ -f "$d.git" ]; then
					echo "Entering '${d/\//}'"; git -C "$d" rev-parse --abbrev-ref HEAD; git -C "$d" status -bs; echo Exiting
				fi
				;;
			esac
		done
	]]
  local submodules_heads = vim.fn.system(script)
  local i = 1
  local entering
  local repo_name
  local repo_branch
  local git_status_submodules = ''
  for s in string.gmatch(submodules_heads, '[^' .. '\n' .. ']+') do
    for w in string.gmatch(s, '[^' .. ' ' .. ']+') do
      if entering == i then
        repo_name = w:gsub("%'", ''):gsub("%'", '')
      elseif entering == i - 1 then
        repo_branch = s
      elseif w == 'Entering' then
        entering = i
      elseif w == 'Exiting' then
        table.insert(items, { git_status_submodules, repo_name, repo_branch })
        git_status_submodules = ''
      elseif w == 'M' and string.find(git_status_submodules, '!') == nil then
        git_status_submodules = git_status_submodules .. '!'
      elseif w == '??' and string.find(git_status_submodules, '+') == nil then
        git_status_submodules = git_status_submodules .. '+'
      elseif w == 'D' and string.find(git_status_submodules, '✘') == nil then
        git_status_submodules = git_status_submodules .. '✘'
      end
      if w == '##' and string.find(git_status_submodules, '⇡') == nil and string.match(s, 'ahead') then
        local ahead = s:match 'ahead (%d+)'
        git_status_submodules = git_status_submodules .. '⇡' .. ahead
      end
      if w == '##' and string.find(git_status_submodules, '⇣') == nil and string.match(s, 'behind') then
        local behind = s:match 'behind (%d+)'
        git_status_submodules = git_status_submodules .. '⇣' .. behind
      end
    end
    i = i + 1
  end

  return items
end

local show_repos = function(opts)
  opts = vim.tbl_extend('force', setup_opts, opts or {})

  local items = prepare_repos()

  if #items == 1 then
    open_git_tool(opts, items[1][2])
  else
    pickers
      .new(opts, {
        prompt_title = 'Git Submodules',
        finder = finders.new_table {
          results = items,
          entry_maker = function(entry)
            local columns = vim.o.columns
            local width = conf.width or conf.layout_config.width or conf.layout_config[conf.layout_strategy].width or columns
            local telescope_width
            if width > 1 then
              telescope_width = width
            else
              telescope_width = math.floor(columns * width)
            end
            local repo_branch_width = math.floor(columns * 0.05)
            local repo_name_width = 25
            local repo_status_width = 10
            local displayer = entry_display.create {
              separator = '',
              items = {
                { width = repo_status_width },
                { width = repo_name_width },
                { width = telescope_width - repo_branch_width - repo_name_width - repo_status_width },
                { remaining = true },
              },
            }
            local make_display = function()
              return displayer {
                { entry[1] },
                { ' ' .. entry[2] },
                { '󰘬 ' .. entry[3] },
              }
            end

            return {
              value = entry[2],
              ordinal = string.format('%s %s', entry[1], entry[2], entry[3]),
              display = make_display,
            }
          end,
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_buf, _)
          actions.select_default:replace(function()
            -- for what ever reason any attempt to open an external window (such as lazygit)
            -- shall be done after closing the buffer manually
            actions.close(prompt_buf)

            open_git_tool(opts, nil)
          end)
          return true
        end,
      })
      :find()
  end
end

if vim.fn.executable 'git' == 0 then
  print 'telescope-git-submodules: git not in path. Cannot register extension.'
  return
else
  return require('telescope').register_extension {
    setup = function(ext_config)
      for k, v in pairs(ext_config) do
        setup_opts[k] = v
      end
    end,
    exports = {
      git_submodules = show_repos,
    },
  }
end
