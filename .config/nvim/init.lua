vim.loader.enable()
require 'custom.options'
require 'custom.keymaps'
require 'custom.autocmds'
require 'custom.filetypes'

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  { 'tpope/vim-sleuth', event = { 'BufReadPost', 'BufNewFile' } },
  { 'fladson/vim-kitty', ft = 'kitty', tag = 'v1.1' },
  { 'folke/todo-comments.nvim', event = { 'BufReadPost', 'BufNewFile' }, dependencies = { 'nvim-lua/plenary.nvim' }, opts = {} },
  { import = 'custom.plugins' },
}, {
  ui = {
    icons = {},
    border = 'single',
  },
})
