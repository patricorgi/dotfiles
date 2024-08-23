require 'custom.options'
require 'custom.keymaps'
require 'custom.autocmds'
require 'custom.filetypes'

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
require('lazy').setup({

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- quick remedy when tab-complete-then-enter fails you, e.g. `nvim init.l`
  { 'mong8se/actually.nvim', lazy = false },

  -- current best multicursor IMHO
  { 'mg979/vim-visual-multi', lazy = true, keys = { '<C-n>' } },

  -- kitty conf file highlight
  { 'fladson/vim-kitty', ft = { 'kitty' } },

  -- Use `opts = {}` to force a plugin to be loaded.
  { 'stevearc/dressing.nvim', event = 'VeryLazy', opts = {} },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VeryLazy', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  { import = 'custom.plugins' },
}, {
  ui = {
    icons = {},
  },
})
