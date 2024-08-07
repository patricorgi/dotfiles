-- [[ Basic Keymaps ]]
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', '<cmd>:q<CR>', { desc = 'Quit current window' })
vim.keymap.set('n', '<C-q>', '<cmd>:qall<CR>', { desc = 'Quit all window' })
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '\\', '<CMD>:sp<CR>', { desc = 'Split window horizontally' })
vim.keymap.set('n', '|', '<CMD>:vsp<CR>', { desc = 'Split window vertically' })
vim.keymap.set('n', ']q', '<cmd>cnext<cr>', { desc = 'Go to next qf item' })
vim.keymap.set('n', '[q', '<cmd>cprev<cr>', { desc = 'Go to prev qf item' })
vim.keymap.set('n', '<C-d>', '5j', { desc = 'Scroll down by 5 lines' })
vim.keymap.set('n', '<C-u>', '5k', { desc = 'Scroll up by 5 lines' })
vim.keymap.set('n', 'L', '<cmd>bnext<cr>', { desc = 'Go to next buffer' })
vim.keymap.set('n', 'H', '<cmd>bprev<cr>', { desc = 'Go to prev buffer' })
vim.keymap.set('n', '+', '<C-w>|<C-w>_')
vim.keymap.set('n', '=', '<C-w>=')
-- close all other buffers except current one
vim.keymap.set('n', '<leader>bc', ':%bdelete|edit#|bdelete#<CR>', { noremap = true, silent = true })
-- vim.keymap.set('n', '<leader>bc', function()
--   local filetypes = { 'OverseerList', 'Terminal' }
--   local current_buf = vim.fn.bufnr '%'
--   local buffers = vim.fn.getbufinfo { bufloaded = 1 }
--
--   for _, buffer in ipairs(buffers) do
--     local bufnr = buffer.bufnr
--     local buf_filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
--
--     -- Close the buffer if it is not the current one and not in the specified filetypes
--     if bufnr ~= current_buf and not vim.tbl_contains(filetypes, buf_filetype) then
--       vim.cmd('bd ' .. bufnr)
--     end
--   end
-- end, { noremap = true, silent = true })

vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], { desc = 'Move focus to the left window' })
vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], { desc = 'Move focus to the lower window' })
vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], { desc = 'Move focus to the upper window' })
vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], { desc = 'Move focus to the right window' })

vim.keymap.set('x', '<leader>p', '"_dp', { desc = 'Paste without overwriting default register' })
