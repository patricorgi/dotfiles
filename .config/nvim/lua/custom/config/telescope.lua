-- The easiest way to use Telescope, is to start by doing something like:
--  :Telescope help_tags

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
local actions = require 'telescope.actions'
require('telescope').setup {
  defaults = {
    sorting_strategy = 'ascending',
    layout_config = {
      horizontal = { prompt_position = 'top', preview_width = 0.55 },
      vertical = { mirror = false },
      width = 0.87,
      height = 0.80,
      preview_cutoff = 120,
    },
    mappings = {
      i = {
        ['<esc>'] = actions.close,
        ['jk'] = actions.close,
      },
    },
    extensions = { ['ui-select'] = {
      require('telescope.themes').get_dropdown(),
    } },
  },
}

pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')
pcall(require('telescope').load_extension, 'git_submodules')

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
end

-- See `:help telescope.builtin`
local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Find Help' })
vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = 'Find Keymaps' })
vim.keymap.set('n', '<leader>ff', function()
  builtin.find_files {
    cwd = vim.fn.getcwd(),
    search_dirs = { vim.fn.getcwd() },
    attach_mappings = function(_, map)
      map('i', '<C-r>', reveal_in_neotree)
      return true
    end,
  }
end, { desc = 'Find Files' })
vim.keymap.set('n', '<leader>fw', '<cmd>Telescope live_grep_args<cr>', { desc = 'Find Word' })
vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = 'Find Diagnostics' })
vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = 'Find Resume' })
vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = 'Find Old Files' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = 'Find existing buffers' })
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope git_submodules<cr>', { desc = 'Find Git submodules' })

-- Slightly advanced example of overriding default behavior and theme
vim.keymap.set('n', '<leader>f/', function()
  -- You can pass additional configuration to Telescope to change the theme, layout, etc.
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    previewer = false,
  })
end, { desc = 'Find / Fuzzily search in current buffer' })

-- It's also possible to pass additional configuration options.
--  See `:help telescope.builtin.live_grep()` for information about particular keys
vim.keymap.set('n', '<leader>s/', function()
  builtin.live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end, { desc = 'Search / in Open Files' })

-- Shortcut for searching your Neovim configuration files
vim.keymap.set('n', '<leader>sn', function()
  builtin.find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = 'Find Neovim files' })
