local custom_pickers = require 'custom.pickers'
vim.keymap.set('i', 'jk', '<esc>', { noremap = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = 'Move cursor down' })
vim.keymap.set('x', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = 'Move cursor down' })
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = 'Move cursor up' })
vim.keymap.set('x', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = 'Move cursor up' })
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '\\', '<CMD>:sp<CR>', { desc = 'Split window horizontally' })
vim.keymap.set('n', '|', '<CMD>:vsp<CR>', { desc = 'Split window vertically' })
vim.keymap.set('n', ']q', '<cmd>cnext<cr>', { desc = 'Go to next qf item' })
vim.keymap.set('n', '[q', '<cmd>cprev<cr>', { desc = 'Go to prev qf item' })
vim.keymap.set('n', '<C-d>', '5j', { desc = 'Scroll down by 5 lines' })
vim.keymap.set('n', '<C-u>', '5k', { desc = 'Scroll up by 5 lines' })
vim.keymap.set('n', 'L', 'gt', { noremap = true, desc = 'Go to next buffer' })
vim.keymap.set('n', 'H', 'gT', { noremap = true, desc = 'Go to prev buffer' })
vim.keymap.set('n', '+', '<C-w>|<C-w>_', { desc = 'Maximize nvim pane' })
vim.keymap.set('n', '=', '<C-w>=', { desc = 'Restore nvim panes' })
-- vim.keymap.set('v', 'p', '"_dP', { noremap = true })
vim.keymap.set('v', '<leader>p', 'p', { noremap = true })
vim.keymap.set('n', '<space>X', '<cmd>source %<cr>', { desc = 'Run this lua file' })
vim.keymap.set('n', '<space>x', ':.lua<cr>', { desc = 'Run this line' })
vim.keymap.set('v', '<space>x', ':lua<cr>', { desc = 'Run selection' })

local feedkeys = vim.api.nvim_feedkeys
local t = vim.api.nvim_replace_termcodes
vim.keymap.set('n', '<leader>tz', function()
  feedkeys(t('<leader>tg', true, true, true), 'm', false)
  feedkeys(t('<leader>th', true, true, true), 'm', false)
  feedkeys(t('<leader>td', true, true, true), 'm', false)
  feedkeys(t('<leader>tt', true, true, true), 'm', false)
end, { noremap = true, silent = true, desc = 'Toggle distraction free' })

vim.keymap.set('n', '<leader>fg', custom_pickers.pick_repositories)
vim.keymap.set('n', '<C-w><C-t>', function()
  local buf = vim.api.nvim_get_current_buf()
  vim.cmd 'tabnew'
  vim.api.nvim_set_current_buf(buf)
end, { desc = 'Open current buffer in new tab' })

local function jump_to_file_lnum_from_all_windows()
  local matches = {}
  local seen = {}

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)

    -- Avoid duplicates if multiple windows show the same buffer
    if not seen[buf] then
      seen[buf] = true
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

      for lnum, line in ipairs(lines) do
        for filepath, lno in string.gmatch(line, '([%w%./~_-]+):(%d+)') do
          table.insert(matches, {
            label = filepath .. ':' .. lno,
            file = filepath,
            lnum = tonumber(lno),
          })
        end
      end
    end
  end

  if vim.tbl_isempty(matches) then
    vim.notify('No file:line patterns found in any window', vim.log.levels.INFO)
    return
  end

  vim.ui.select(matches, {
    prompt = 'Jump to file:line',
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if choice then
      vim.cmd('edit ' .. choice.file)
      vim.api.nvim_win_set_cursor(0, { choice.lnum, 0 })
    end
  end)
end

vim.keymap.set('n', '<leader>fJ', jump_to_file_lnum_from_all_windows, { desc = 'Jump to file:line from any window' })

local function send_to_terminal(term_name, init_cmd)
  local mode = vim.fn.mode()
  local text

  if mode == "v" or mode == "V" or mode == "\22" then
    -- Yank visual selection without clobbering registers
    vim.cmd('normal! "vy')
    text = vim.fn.getreg('v')  -- we used the v register
  else
    -- Get entire buffer
    text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  end

  -- update DISPLAY
  local handle = io.popen [[bash -c '[ -n "$TMUX" ] && export DISPLAY=$(tmux show-env | sed -n "s/^DISPLAY=//p"); echo -n $DISPLAY']]
  local display_value
  if handle then
    display_value = handle:read '*a'
    handle:close()
  end

  local target_buf = nil
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == 'terminal' and vim.api.nvim_buf_get_name(buf):match(term_name .. '$') then
      target_buf = buf
      break
    end
  end

  -- If no ROOT terminal, create one
  if not target_buf then
    if init_cmd then
      vim.cmd("vsplit | term bash -i -l -c '[ -n \"$TMUX\" ] && export DISPLAY=$(tmux show-env | sed -n 's/^DISPLAY=//p'); " .. init_cmd .. "'")
    else
      vim.cmd "vsplit | term bash -i -l -c '[ -n \"$TMUX\" ] && export DISPLAY=$(tmux show-env | sed -n 's/^DISPLAY=//p');'"
    end
    target_buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_name(target_buf, term_name)
    -- vim.b.term_name = 'ROOT'
  end

  -- Send to ROOT terminal
  local chan_id = vim.b[target_buf].terminal_job_id
  if term_name == 'term:ROOT' then
    vim.fn.chansend(chan_id, 'gSystem->Setenv("DISPLAY", "' .. display_value .. '");' .. '\n')
  end
  vim.fn.chansend(chan_id, text)
end

vim.keymap.set('n', '<leader>sR', function()
  send_to_terminal('term:ROOT', 'r')
end, { desc = 'Send to term:ROOT' })
vim.keymap.set('v', '<leader>sr', function()
  send_to_terminal('term:ROOT', 'r')
end, { desc = 'Send to term:ROOT' })
vim.keymap.set('v', '<leader>sp', function()
  send_to_terminal('term:python', 'python3')
end, { desc = 'Send to term:python' })
vim.keymap.set('n', '<leader>tp', function()
  local terminals = {
    { name = 'ROOT', cmd = "bash -i -l -c '[ -n \"$TMUX\" ] && export DISPLAY=$(tmux show-env | sed -n 's/^DISPLAY=//p'); r'" },
    { name = 'Python', cmd = 'python3' },
    { name = 'Bash', cmd = '' },
    { name = 'My Script', cmd = "bash -i -l -c '~/myscript.sh'" },
  }
  vim.ui.select(terminals, {
    prompt = 'Pick terminal:',
    format_item = function(item)
      return item.name
    end,
  }, function(choice)
    if choice then
      vim.cmd('split | terminal ' .. choice.cmd)
      -- name the buffer after its terminal preset
      local buf = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_name(buf, 'term:' .. choice.name)
      vim.b.term_name = choice.name
    end
  end)
end, { desc = 'Pick predefined terminal' })

vim.keymap.set("i", "<C-x><C-d>", function()
  if vim.api.nvim_win_get_config(0).relative == "" then
   return vim.fn.expand("%:p:h")
  else
  -- get window before current one
  local winid = vim.fn.win_getid(vim.fn.winnr("#"))
  if winid == 0 then
    return ""  -- no previous window
  end
  -- get buffer of that window
  local bufnr = vim.api.nvim_win_get_buf(winid)
  -- expand to directory
  return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":p:h")
  end
end, { expr = true, noremap = true })

