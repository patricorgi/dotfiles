local builtin = require 'telescope.builtin'
local actions_state = require 'telescope.actions.state'
local reveal_in_neotree = function()
  local selection = actions_state.get_selected_entry()
  local filename = selection.filename
  if filename == nil then
    filename = selection[1]
  end
  require('neo-tree.command').execute {
    action = 'focus', -- OPTIONAL, this is the default value
    source = 'filesystem', -- OPTIONAL, this is the default value
    position = 'left', -- OPTIONAL, this is the default value
    reveal_file = filename, -- path to file or folder to reveal
    reveal_force_cwd = true, -- change cwd without asking if needed
  }
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)
end
require('search').setup {
  mappings = { -- optional: configure the mappings for switching tabs (will be set in normal and insert mode(!))
    next = '<Tab>',
    prev = '<S-Tab>',
  },
  append_tabs = { -- append_tabs will add the provided tabs to the default ones
    {
      'Recent',
      builtin.oldfiles,
    },
    {
      'Buffers',
      builtin.buffers,
    },
  },
  -- its also possible to overwrite the default tabs using the tabs key instead of append_tabs
  tabs = {
    {
      'Files',
      function()
        builtin.find_files {
          cwd = vim.fn.getcwd(),
          search_dirs = { vim.fn.getcwd() },
          attach_mappings = function(_, map)
            map('i', '<C-r>', reveal_in_neotree)
            return true
          end,
        }
      end,
    },
  },
}

vim.keymap.set('n', '<leader>ff', function()
  require('search').open { tab_name = 'Files' }
end, { desc = 'Find File' })
vim.keymap.set('n', '<leader><leader>', function()
  require('search').open { tab_name = 'Buffers' }
end, { desc = 'Find Buffer' })
vim.keymap.set('n', '<leader>fo', function()
  require('search').open { tab_name = 'Recent' }
end, { desc = 'Find Recent File' })
