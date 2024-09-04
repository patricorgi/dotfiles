-- The easiest way to use Telescope, is to start by doing something like:
--  :Telescope help_tags

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
local actions = require 'telescope.actions'
local custom_utils = require 'custom.utils'
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

-- See `:help telescope.builtin`
local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Find Help' })
vim.keymap.set('n', '<leader>fH', builtin.highlights, { desc = 'Find Highlights' })
vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = 'Find Keymaps' })
vim.keymap.set('n', '<leader>fw', '<cmd>Telescope live_grep_args<cr>', { desc = 'Find Word' })
vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = 'Find Diagnostics' })
vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = 'Find Resume' })
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope git_submodules<cr>', { desc = 'Find Git submodules' })
vim.keymap.set('n', '<leader>fs', function()
  if custom_utils.is_lsp_attached() then
    builtin.lsp_document_symbols()
  else
    require('telescope').extensions.aerial.aerial()
  end
  -- -- require('telescope').extensions.aerial.aerial()
  -- local status_ok, _ = pcall(require('telescope.builtin').lsp_document_symbols)
  -- if status_ok then
  --   require('telescope.builtin').lsp_document_symbols()
  -- else
  --   require('telescope').extensions.aerial.aerial()
  -- end
end, { desc = 'Find Document Symbols' })
vim.keymap.set('n', '<leader>ls', require('aerial').toggle, { desc = 'Find Document Symbols' })
vim.keymap.set('n', '<leader>fS', builtin.lsp_dynamic_workspace_symbols, { desc = 'Find Workspace Symbols' })

-- Slightly advanced example of overriding default behavior and theme
vim.keymap.set('n', '<leader>f/', function()
  -- You can pass additional configuration to Telescope to change the theme, layout, etc.
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_ivy {
    previewer = true,
    skip_empty_lines = true,
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
  builtin.find_files {
    cwd = vim.env.HOME .. '/dotfiles',
    attach_mappings = function(_, map)
      map('i', '<C-r>', custom_utils.reveal_in_neotree)
      map('i', '<CR>', custom_utils.edit_respect_winfixbuf)
      return true
    end,
  }
end, { desc = 'Find Config Files' })

vim.keymap.set('n', '<leader>tm', '<CMD>Telescope tmux-awesome-manager list_terms<CR>', { desc = 'TAM list_terms' })
