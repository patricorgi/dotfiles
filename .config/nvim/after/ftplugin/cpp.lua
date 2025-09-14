if vim.b.did_my_ftplugin then
  return
end
vim.b.did_my_ftplugin = true

if vim.fn.executable("lcg-clang-format-8.0.0")  == 1 then
    vim.keymap.set('n', '<leader>lf', '<cmd>!lcg-clang-format-8.0.0 %<cr>' )
else
    vim.keymap.set("v", "<leader>lf", ":%!clang-format<CR>")
end

require("meow.yarn").setup({})
