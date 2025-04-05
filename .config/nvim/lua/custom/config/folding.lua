vim.o.foldcolumn = '0' -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.foldmethod = 'expr'
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

-- Source: https://www.reddit.com/r/neovim/comments/1fzn1zt/custom_fold_text_function_with_treesitter_syntax/
local function fold_virt_text(result, start_text, lnum)
  local text = ''
  local hl
  for i = 1, #start_text do
    local char = start_text:sub(i, i)
    local new_hl

    -- if semantic tokens unavailable, use treesitter hl
    local sem_tokens = vim.lsp.semantic_tokens.get_at_pos(0, lnum, i - 1)
    if sem_tokens and #sem_tokens > 0 then
      new_hl = '@' .. sem_tokens[#sem_tokens].type
    else
      local captured_highlights = vim.treesitter.get_captures_at_pos(0, lnum, i - 1)
      if captured_highlights[#captured_highlights] then
        new_hl = '@' .. captured_highlights[#captured_highlights].capture
      end
    end

    if new_hl then
      if new_hl ~= hl then
        -- as soon as new hl appears, push substring with current hl to table
        table.insert(result, { text, hl })
        text = ''
        hl = nil
      end
      text = text .. char
      hl = new_hl
    else
      text = text .. char
    end
  end
  table.insert(result, { text, hl })
end
function _G.custom_foldtext()
  local start_text = vim.fn.getline(vim.v.foldstart):gsub('\t', string.rep(' ', vim.o.tabstop))
  local nline = vim.v.foldend - vim.v.foldstart
  local result = {}
  fold_virt_text(result, start_text, vim.v.foldstart - 1)
  -- table.insert(result, { ' ', nil })
  -- table.insert(result, { '◖', '@comment.warning.gitcommit' })
  -- table.insert(result, { '↙ ' .. nline .. ' lines', '@comment.warning' })
  -- table.insert(result, { '◗', '@comment.warning.gitcommit' })
  table.insert(result, { '  ', nil })
  table.insert(result, { '󰛁  ' .. nline .. ' lines folded', '@comment' })
  return result
end
vim.opt.foldtext = 'v:lua.custom_foldtext()'
vim.keymap.set('n', '<CR>', 'za', { desc = 'Toggle fold under cursor' })
