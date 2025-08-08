local actions = require 'telescope.actions'
local builtin = require 'telescope.builtin'
local custom_utils = require 'custom.utils'
require('telescope').setup {
  defaults = {
    sorting_strategy = 'ascending',
    borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
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
    prompt_prefix = ' ',
    selection_caret = ' ',
  },
}

-- keymaps
vim.keymap.set('n', '<leader>fo', function()
  builtin.oldfiles {
    attach_mappings = function(_, map)
      map('i', '<C-r>', custom_utils.reveal_in_neotree)
      map('i', '<CR>', custom_utils.edit_respect_winfixbuf)
      return true
    end,
  }
end, { desc = 'Find Recent' })
vim.keymap.set('n', '<leader><leader>', function()
  builtin.buffers {
    attach_mappings = function(_, map)
      map('i', '<C-r>', custom_utils.reveal_in_neotree)
      map('i', '<CR>', custom_utils.edit_respect_winfixbuf)
      return true
    end,
  }
end, { desc = 'Find Buffer' })
vim.keymap.set('n', '<leader>ff', function()
  builtin.find_files {
    cwd = vim.fn.getcwd(),
    search_dirs = { vim.fn.getcwd() },
    attach_mappings = function(_, map)
      map('i', '<C-r>', custom_utils.reveal_in_neotree)
      map('i', '<CR>', custom_utils.edit_respect_winfixbuf)
      return true
    end,
  }
end, { desc = 'Find File' })

-- FIXME:
-- require('telescope').load_extension('git_submodules')

vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Find Help' })
vim.keymap.set('n', '<leader>fH', builtin.highlights, { desc = 'Find Highlights' })
vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = 'Find Keymaps' })
vim.keymap.set('n', '<leader>fm', builtin.marks, { desc = 'Find Marks' })
vim.keymap.set('n', '<leader>fw', '<cmd>Telescope live_grep_args<cr>', { desc = 'Find Word' })
vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = 'Find Diagnostics' })
vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = 'Find Resume' })
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope git_submodules<cr>', { desc = 'Find Git submodules' })
vim.keymap.set('n', '<leader>ls', require('aerial').toggle, { desc = 'Find Document Symbols' })
vim.keymap.set('n', '<leader>fS', builtin.lsp_dynamic_workspace_symbols, { desc = 'Find Workspace Symbols' })
vim.keymap.set('n', '<leader>fs', function()
  if custom_utils.is_lsp_attached() then
    builtin.lsp_document_symbols { symbol_width = 0.8 }
  else
    require('telescope').extensions.aerial.aerial()
  end
end, { desc = 'Find Document Symbols' })
vim.keymap.set('n', '<leader>f/', function()
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_ivy {
    previewer = true,
    skip_empty_lines = true,
  })
end, { desc = 'Find / Fuzzily search in current buffer' })
vim.keymap.set('n', '<leader>fc', function()
  builtin.find_files {
    cwd = vim.env.HOME .. '/dotfiles',
    attach_mappings = function(_, map)
      map('i', '<C-r>', custom_utils.reveal_in_neotree)
      map('i', '<CR>', custom_utils.edit_respect_winfixbuf)
      return true
    end,
  }
end, { desc = 'Find Config Files' })
