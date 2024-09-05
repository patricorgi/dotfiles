require('obsidian').setup {
  workspaces = {
    {
      name = 'Obsidian',
      path = '~/Documents/Obsidian Vault',
    },
  },
  daily_notes = {
    folder = 'daily',
    date_format = '%Y-%m-%d',
    default_tags = {},
    template = 'templates/daily.md',
  },
  templates = {
    folder = 'templates',
    date_format = '%Y-%m-%d',
    time_format = '%H:%M',
  },
  follow_url_func = function(url)
    vim.ui.open(url)
  end,
  attachments = {
    confirm_img_paste = true,
    img_folder = 'attachments',
    img_text_func = function(client, path)
      path = client:vault_relative_path(path) or path
      return string.format('![%s](%s)', path.name, path)
    end,
  },
  open_app_foreground = true,
  note_path_func = function(spec)
    local path = spec.dir / tostring(spec.title)
    return path:with_suffix '.md'
  end,
  ui = {
    update_debounce = 3000,
  },
}
vim.keymap.set('n', '<leader>nt', '<cmd>ObsidianToday<cr>', { desc = 'Note Today' })
vim.keymap.set('n', '<leader>no', '<cmd>ObsidianOpen<cr>', { desc = 'Note Open in App' })
vim.keymap.set('n', '<leader>ns', '<cmd>ObsidianSearch<cr>', { desc = 'Note Search' })
