if vim.b.did_my_ftplugin then
  return
end
vim.b.did_my_ftplugin = true
vim.keymap.set('n', '<leader>lb', function()
  Snacks.picker.grep_buffers {
    finder = 'grep',
    format = 'file',
    prompt = ' ',
    -- search = '^\\s*- \\[ \\]',
    search = '\\begin{frame}',
    regex = false,
    live = false,
    args = {},
    on_show = function()
      vim.cmd.stopinsert()
    end,
    buffers = false,
    supports_live = false,
    layout = 'left',
  }
end, { desc = 'Search Beamer Frames' })
