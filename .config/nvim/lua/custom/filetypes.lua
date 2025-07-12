vim.filetype.add {
  extension = {
    qmt = 'qmt',
    ipynb = 'ipynb',
    ent = 'xml',
    h = function(_, bufnr)
      local first_line = vim.api.nvim_buf_get_lines(bufnr, 1, 2, false)[1] or ''
      if first_line:match 'NVIDIA Corporation' then
        return 'cuda'
      end
      return 'cpp'
    end,
  },
  filename = {
    ['Snakefile'] = 'snakemake',
  },
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'help', 'qf', 'dap-float' },
  callback = function()
    vim.keymap.set('n', 'q', '<CMD>quit<CR>', { buffer = true, silent = true })
  end,
})

vim.api.nvim_create_autocmd('BufRead', {
  pattern = vim.fn.expand '~' .. '/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault/*.md',
  callback = function()
    local function parse_date_line(date_line)
      local home = os.getenv 'HOME'
      local year, month, day, weekday = date_line:match '%[%[(%d+)%-(%d+)%-(%d+)%-(%w+)%]%]'
      if not (year and month and day and weekday) then
        print 'No valid date found in the line'
        return nil
      end
      local note_dir = vim.fn.expand '~' .. '/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault/daily'
      local note_name = string.format('%s-%s-%s-%s.md', year, month, day, weekday)
      return note_dir, note_name
    end
    local function get_daily_note_path(date_line)
      local note_dir, note_name = parse_date_line(date_line)
      if not note_dir or not note_name then
        return nil
      end
      return note_dir .. '/' .. note_name
    end
    local function create_daily_note(date_line)
      local full_path = get_daily_note_path(date_line)
      if not full_path then
        return
      end
      local note_dir = full_path:match '(.*/)' -- Extract directory path from full path
      -- Ensure the directory exists
      vim.fn.mkdir(note_dir, 'p')
      -- Check if the file exists and create it if it doesn't
      if vim.fn.filereadable(full_path) == 0 then
        local file = io.open(full_path, 'w')
        if file then
          vim.cmd('edit ' .. vim.fn.fnameescape(full_path))
          vim.cmd 'bd!'
          vim.api.nvim_echo({
            { 'CREATED DAILY NOTE\n', 'WarningMsg' },
            { full_path, 'WarningMsg' },
          }, false, {})
        else
          print('Failed to create file: ' .. full_path)
        end
      else
        print('Daily note already exists: ' .. full_path)
      end
    end
    local function switch_to_daily_note(date_line)
      local full_path = get_daily_note_path(date_line)
      if not full_path then
        return
      end
      create_daily_note(date_line)
      vim.cmd('edit ' .. vim.fn.fnameescape(full_path))
    end
    -- Your command or function here
    vim.keymap.set('n', '<leader>ot', function()
      local current_line = vim.api.nvim_get_current_line()
      local date_line = current_line:match '%[%[%d+%-%d+%-%d+%-%w+%]%]' or ('[[' .. os.date '%Y-%m-%d-%A' .. ']]')
      switch_to_daily_note(date_line)
    end, { desc = '[P]Go to or create daily note' })
  end,
})
