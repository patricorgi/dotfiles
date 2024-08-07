require 'custom.options'
require 'custom.keymaps'
require 'custom.autocmds'
require 'custom.filetypes'

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
require('lazy').setup({
  { 'mong8se/actually.nvim', lazy = false }, -- remedy for using partial filename
  { 'tpope/vim-sleuth' }, -- Detect tabstop and shiftwidth automatically
  { 'mg979/vim-visual-multi', lazy = true, keys = { '<C-n>' } }, -- current best multicursor IMHO
  -- { 'dstein64/vim-startuptime', lazy = false },
  { 'fladson/vim-kitty', ft = { 'kitty' } }, -- kitty conf file highlight
  {
    'christoomey/vim-tmux-navigator',
    keys = {
      { '<c-h>', '<cmd><C-U>TmuxNavigateLeft<cr>' },
      { '<c-j>', '<cmd><C-U>TmuxNavigateDown<cr>' },
      { '<c-k>', '<cmd><C-U>TmuxNavigateUp<cr>' },
      { '<c-l>', '<cmd><C-U>TmuxNavigateRight<cr>' },
      { '<c-\\>', '<cmd><C-U>TmuxNavigatePrevious<cr>' },
    },
  },

  -- Use `opts = {}` to force a plugin to be loaded.
  { 'stevearc/dressing.nvim', event = 'VeryLazy', opts = {} },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VeryLazy', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --    For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
  { import = 'custom.plugins' },
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = {},
  },
})
