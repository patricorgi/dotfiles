require('render-markdown').setup {
  debounce = 100,
  render_modes = { 'n', 'c', 't' },
  file_types = { 'markdown', 'Avante' },
  heading = {
    icons = { '󰉫 ', '󰉬 ', '󰉭 ', '󰉮 ', '󰉯 ', '󰉰 ' },
    -- position = 'inline',
    right_pad = 1,
  },
  bullet = {
    enabled = true,
    render_modes = true,
    icons = { '◍', '⏵', '♦', '⊙' },
    highlight = 'RenderMarkdownBullet',
  },
  link = {
    wiki = { icon = '', highlight = 'RenderMarkdownWikiLink' },
  },
  sign = { enabled = false },
  latex = {
    enabled = true,
    converter = 'latex2text',
    highlight = 'RenderMarkdownMath',
    top_pad = 0,
    bottom_pad = 0,
  },
  checkbox = {
    enabled = true,
    position = 'inline',
    right_pad = 0,
    custom = {
      question = { raw = '[?]', rendered = ' ', highlight = 'RenderMarkdownError' },
      ongoing = { raw = '[>]', rendered = ' ', highlight = 'RenderMarkdownSuccess' },
      canceled = { raw = '[~]', rendered = '󰗨 ', highlight = 'ObsidianTilde' },
      important = { raw = '[!]', rendered = ' ', highlight = 'RenderMarkdownWarn' },
      favorite = { raw = '[^]', rendered = ' ', highlight = 'RenderMarkdownMath' },
    },
  },
  quote = {
    repeat_linebreak = true,
  },
}

-- local blink = require 'blink.cmp'
-- blink.add_filetype_source('markdown', 'render-markdown')
-- blink.add_provider('render-markdown', {
--   name = 'RenderMarkdown',
--   module = 'render-markdown.integ.blink',
--   fallbacks = { 'lsp' },
-- })
