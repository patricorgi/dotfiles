local builtin = require 'telescope.builtin'
local custom_utils = require 'custom.utils'

require('search').setup {
  mappings = { -- optional: configure the mappings for switching tabs (will be set in normal and insert mode(!))
    next = '<Tab>',
    prev = '<S-Tab>',
  },
  append_tabs = { -- append_tabs will add the provided tabs to the default ones
    {
      'Recent',
      function()
        builtin.oldfiles {
          attach_mappings = function(_, map)
            map('i', '<C-r>', custom_utils.reveal_in_neotree)
            map('i', '<CR>', custom_utils.edit_respect_winfixbuf)
            return true
          end,
        }
      end,
    },
    {
      'Buffers',
      function()
        builtin.buffers {
          attach_mappings = function(_, map)
            map('i', '<C-r>', custom_utils.reveal_in_neotree)
            map('i', '<CR>', custom_utils.edit_respect_winfixbuf)
            return true
          end,
        }
      end,
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
            map('i', '<C-r>', custom_utils.reveal_in_neotree)
            map('i', '<CR>', custom_utils.edit_respect_winfixbuf)
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
