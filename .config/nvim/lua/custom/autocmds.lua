-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`
local custom_utils = require("custom.utils")

local function augroup(name)
  return vim.api.nvim_create_augroup('lazyvim_' .. name, { clear = true })
end

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank({higroup = "CurSearch"})
  end,
})

-- Restore cursor position
vim.api.nvim_create_autocmd({ 'BufReadPost' }, {
  pattern = { '*' },
  callback = function()
    vim.api.nvim_exec2('silent! normal! g`"zv', { output = false })
  end,
})

-- Big file
vim.filetype.add {
  pattern = {
    ['.*'] = {
      function(path, buf)
        if vim.bo[buf].filetype ~= 'bigfile' and path and vim.fn.getfsize(path) > vim.g.bigfile_size then
          vim.opt.cursorline = false
          return 'bigfile'
        else
          return nil
        end
      end,
    },
  },
}

vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = augroup 'bigfile',
  pattern = 'bigfile',
  callback = function(ev)
    vim.b.minianimate_disable = true
    vim.schedule(function()
      vim.bo[ev.buf].syntax = vim.filetype.match { buf = ev.buf } or ''
    end)
  end,
})

-- vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
--   pattern = "*.C",
--   callback = function()
--     vim.bo.filetype = "c"   -- treat as C instead of cpp
--     vim.notify("Disabling diagnostic for .C")
--     vim.diagnostic.enable(false, {bufnr = 0})
--   end,
--   group = vim.api.nvim_create_augroup("UppercaseC", { clear = true }),
-- })

vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '*',
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})

vim.api.nvim_create_augroup('IrreplaceableWindows', { clear = true })
vim.api.nvim_create_autocmd('BufWinEnter', {
  group = 'IrreplaceableWindows',
  pattern = '*',
  callback = function()
    local filetypes = { 'OverseerList', 'neo-tree' }
    local buftypes = { 'nofile', 'terminal' }
    if vim.tbl_contains(buftypes, vim.bo.buftype) and vim.tbl_contains(filetypes, vim.bo.filetype) then
      vim.cmd 'set winfixbuf'
    end
  end,
})

vim.api.nvim_create_autocmd('VimResized', {
  pattern = '*',
  callback = function()
    -- File buffers
    vim.cmd 'wincmd =' -- Equalize window sizes

    -- DAP UI
    custom_utils.func_on_window('dapui_stacks', function ()
        require 'dapui'.open({ reset = true })
    end)

    -- OverseerList
    custom_utils.reset_overseerlist_width()
  end,
})
-- Global mapping for normal windows
vim.keymap.set('n', '<CR>', 'za', { desc = 'Toggle fold under cursor' })

-- Override mapping in quickfix window
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'qf',
  callback = function()
    -- Unmap <CR> in quickfix window (if needed)
    vim.keymap.set('n', '<CR>', '<CR>', { buffer = true, desc = 'Default Enter in quickfix' })
  end,
})
