require('render-markdown').setup {
  debounce = 100,
  render_modes = { 'n', 'c', 't' },
  anti_conceal = {
    enabled = true,
    disabled_modes = { 'n' },
  },
  file_types = { 'markdown', 'Avante' },
  heading = {
    render_modes = true,
    icons = { ' 󰼏 ', ' 󰎨 ', ' 󰼑 ', ' 󰎲 ', ' 󰼓 ', ' 󰎴 ' },
  },
  bullet = {
    enabled = true,
    render_modes = true,
    icons = { '◍', '◯', '𜲂', '•' },
    highlight = 'RenderMarkdownBullet',
  },
  link = {
    wiki = { icon = '', highlight = 'RenderMarkdownWikiLink' },
    hyperlink = ' ',
    image = ' ',
    custom = {
      gitlab = { pattern = 'gitlab', icon = ' ' },
      github = { pattern = 'github', icon = '󰮠 ' },
    },
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
  code = {
    highlight_inline = 'RenderMarkdownCodeInfo',
    render_modes = true,
    position = 'right',
    width = 'block',
    left_margin = 1,
    left_pad = 1,
    right_pad = 1,
    min_width = 80,
    border = 'thin',
    language_icon = true,
    language_name = true,
  },
}

-- local blink = require 'blink.cmp'
-- blink.add_filetype_source('markdown', 'render-markdown')
-- blink.add_provider('render-markdown', {
--   name = 'RenderMarkdown',
--   module = 'render-markdown.integ.blink',
--   fallbacks = { 'lsp' },
-- })
