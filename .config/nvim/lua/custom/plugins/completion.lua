return {
  'saghen/blink.cmp',
  event = { 'BufReadPost', 'BufNewFile' },
  version = '1.*',
  opts = {
    completion = {
      documentation = {
        auto_show = true,
      },
    },
    keymap = {
      ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
      ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
    },
    signature = {
      enabled = true,
    },
    cmdline = {
      completion = {
        menu = {
          auto_show = true,
        },
      },
    },
    sources = {
      providers = {
        snippets = { score_offset = 1000 },
      },
    },
  },
}
