vim.loader.enable()
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true
vim.g.markdown_folding = 1
vim.opt.linebreak = true
vim.g.simple_indicator_on = false
vim.o.winborder = 'rounded'
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4

-- [[ Setting options ]]
-- See `:help vim.opt`
--  For more options, you can see `:help option-list`
vim.opt.termguicolors = true

-- Make line numbers default
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.signcolumn = 'yes'
vim.opt.numberwidth = 4

-- enable soft line wrap
vim.opt.wrap = true

-- only one statusline
vim.opt.laststatus = 3

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'auto'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeout = false

-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 5

-- Big file limit
vim.g.bigfile_size = 1024 * 1024 * 1.5 -- 1.5 MB

-- folding
require 'custom.config.folding'
