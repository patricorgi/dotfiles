vim.lsp.enable 'marksman'
vim.o.wrap = false
vim.opt.conceallevel = 2
vim.keymap.set('n', 'gx', function()
  local line = vim.fn.getline '.'
  local cursor_col = vim.fn.col '.'
  local pos = 1
  while pos <= #line do
    local open_bracket = line:find('%[', pos)
    if not open_bracket then
      break
    end
    local close_bracket = line:find('%]', open_bracket + 1)
    if not close_bracket then
      break
    end
    local open_paren = line:find('%(', close_bracket + 1)
    if not open_paren then
      break
    end
    local close_paren = line:find('%)', open_paren + 1)
    if not close_paren then
      break
    end
    if (cursor_col >= open_bracket and cursor_col <= close_bracket) or (cursor_col >= open_paren and cursor_col <= close_paren) then
      local url = line:sub(open_paren + 1, close_paren - 1)
      vim.ui.open(url)
      return
    end
    pos = close_paren + 1
  end
  vim.cmd 'normal! gx'
end, { buffer = true, desc = 'URL opener for markdown' })
