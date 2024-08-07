require('telescope').load_extension 'tmux-awesome-manager'
require('tmux-awesome-manager').setup {
  per_project_commands = { -- Configure your per project servers with
    -- project name = { { cmd, name } }
    ['stack-ut-shifter'] = { { cmd = 'ls', name = 'ls' }, { cmd = 'lh', name = 'lh' } },
    front = { { cmd = 'yarn dev', name = 'react server' } },
  },
  session_name = 'Neovim Terminals',
  use_icon = false, -- use prefix icon
  icon = ' ', -- Prefix icon to use
  project_open_as = 'pane', -- Open per_project_commands as.  Default: separated_session
  open_new_as = 'pane',
  default_size = '50%', -- on panes, the default size
  visit_first_call = true,
  -- open_new_as = 'window' -- open new command as.  options: pane, window, separated_session.
}

local tmux = require 'tmux-awesome-manager.src.term'

local set = function(key, opts)
  vim.keymap.set('n', key, tmux.run(opts), { silent = true, noremap = true, desc = opts.name })
end

local function map(cmd, name, pane_id, visit_first_call, focus_when_call)
  tmux.run { cmd = cmd, name = name, pane_id = pane_id, visit_first_call = visit_first_call or false, focus_when_call = focus_when_call or false }
end
-- make commands
local projects = { 'Boole', 'Rec', 'Alignment', 'Moore', 'Gauss', 'LHCb', 'Detector' }
for _, project in ipairs(projects) do
  map('make ' .. project, 'make ' .. project, 'make')
end

-- visualizations
map("bash -c 'utils/run-env Detector geoDisplay Detector/compact/run3/trunk/debug/UT_debug.xml -level 9'", 'geoDisplay UT', 'geoDisplay')
map("bash -c 'utils/run-env Detector geoDisplay Detector/compact/run3/trunk/LHCb.xml -level 9'", 'geoDisplay LHCb', 'geoDisplay')
map(
  "bash -c 'utils/run-env Detector geoPluginRun -interpreter -input file:Detector/compact/run3/trunk/debug/UT_debug.xml -plugin DD4hep_VolumeDump'",
  'VolumeDump UT',
  'VolumeDump',
  true,
  true
)
map(
  "bash -c 'utils/run-env Detector geoPluginRun -interpreter -input file:Detector/compact/run3/trunk/debug/UT_debug.xml -plugin DD4hep_DetectorDump'",
  'DetectorDump UT',
  'DetectorDump',
  true,
  true
)

-- source control
vim.keymap.set(
  'n',
  '<leader>sc',
  tmux.run {
    cmd = "bash -i -c 'sc | less'",
    name = 'Source Control',
    pane_id = 'source_control',
    open_as = 'pane',
    orientation = 'horizontal',
    close_on_timer = 1,
    visit_first_call = false, -- will not focus the pane
    focus_when_call = false, -- Instead of focusing, will open a new pane in the same place as before
  },
  { desc = 'Source Control' }
)

-- run scripts
tmux.run {
  cmd = 'python3 ' .. vim.fn.expand '%',
  name = 'Run Python Script',
  pane_id = 'PythonScript',
  orientation = 'horizontal',
  visit_first_call = true,
  focus_when_call = true,
}
tmux.run {
  cmd = 'sh ' .. vim.fn.expand '%',
  name = 'Run Shell Script',
  pane_id = 'ShellScript',
  orientation = 'horizontal',
  visit_first_call = true,
  focus_when_call = true,
}

-- make
tmux.run {
  cmd = 'make %1',
  name = 'make',
  questions = {
    { question = 'software name: ', required = true },
  },
}
