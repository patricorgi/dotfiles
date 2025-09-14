if vim.b.did_my_ftplugin then
  return
end
vim.b.did_my_ftplugin = true
vim.lsp.enable 'lua_ls'
vim.lsp.enable 'stylua'
