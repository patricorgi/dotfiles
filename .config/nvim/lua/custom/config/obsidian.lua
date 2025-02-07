local vault_path = vim.fn.expand '~' .. '/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault'
---@diagnostic disable: missing-fields
require('obsidian').setup {
  workspaces = {
    {
      name = 'Obsidian Vault',
      path = vault_path,
    },
  },
  templates = {
    folder = 'templates',
  },
  daily_notes = {
    folder = 'daily',
    template = 'daily.md',
  },
  open_app_foreground = true,
  completion = {
    nvim_cmp = true,
  },
  ui = {
    enable = false, -- set to false to disable all additional syntax features
    update_debounce = 200, -- update delay after a text change (in milliseconds)
    max_file_length = 5000, -- disable UI features for files with more than this many lines
    bullets = { char = '•', hl_group = 'ObsidianBullet' },
    external_link_icon = { char = '', hl_group = 'ObsidianExtLinkIcon' },
    reference_text = { hl_group = 'ObsidianRefText' },
    highlight_text = { hl_group = 'ObsidianHighlightText' },
    tags = { hl_group = 'ObsidianTag' },
    block_ids = { hl_group = 'ObsidianBlockID' },
    hl_groups = {
      -- The options are passed directly to `vim.api.nvim_set_hl()`. See `:help nvim_set_hl`.
      ObsidianTodo = { bold = true, fg = '#f78c6c' },
      ObsidianDone = { bold = true, fg = '#89ddff' },
      ObsidianRightArrow = { bold = true, fg = '#f78c6c' },
      ObsidianTilde = { bold = true, fg = '#ff5370' },
      ObsidianImportant = { bold = true, fg = '#d20f39' },
      ObsidianBullet = { bold = true, fg = '#89ddff' },
      ObsidianRefText = { underline = true, fg = '#c792ea' },
      ObsidianExtLinkIcon = { fg = '#c792ea' },
      ObsidianTag = { italic = true, fg = '#89ddff' },
      ObsidianBlockID = { italic = true, fg = '#89ddff' },
      ObsidianHighlightText = { bg = '#75662e' },
    },
  },
  attachments = {
    img_folder = 'attachments',

    ---@return string
    img_name_func = function()
      return string.format('%s-', os.time())
    end,

    ---@param client obsidian.Client
    ---@param path obsidian.Path the absolute path to the image file
    ---@return string
    img_text_func = function(client, path)
      path = client:vault_relative_path(path) or path
      return string.format('![%s](%s)', path.name, path)
    end,
  },
}

vim.keymap.set('n', '<leader>oo', '<cmd>ObsidianQuickSwitch<cr>', { desc = 'Obsidian: Quick Switch' })
vim.keymap.set('n', '<leader>oO', '<cmd>ObsidianOpen<cr>', { desc = 'Obsidian: Open' })
vim.keymap.set('n', '<leader>ot', '<cmd>ObsidianToday<cr>', { desc = 'Obsidian: Today' })
vim.keymap.set('n', '<leader>oT', '<cmd>ObsidianDailies<cr>', { desc = 'Obsidian: Dailies' })

package.loaded['nvim-cmp'] = package.loaded['blink.compat']
local cmp = require 'cmp'
cmp.register_source('obsidian', require('cmp_obsidian').new())
cmp.register_source('obsidian_new', require('cmp_obsidian_new').new())
cmp.register_source('obsidian_tags', require('cmp_obsidian_tags').new())

local blink = require 'blink.cmp'
blink.add_filetype_source('markdown', 'obsidian')
blink.add_filetype_source('markdown', 'obsidian_new')
blink.add_filetype_source('markdown', 'obsidian_tags')
blink.add_provider('obsidian', { name = 'obsidian', module = 'blink.compat.source' })
blink.add_provider('obsidian_new', { name = 'obsidian_new', module = 'blink.compat.source' })
blink.add_provider('obsidian_tags', { name = 'obsidian_tags', module = 'blink.compat.source' })
