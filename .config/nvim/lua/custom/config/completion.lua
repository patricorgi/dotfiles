require('blink.cmp').setup {
  sources = {
    providers = {
      snippets = { score_offset = 1000 },
    },
  },
  cmdline = {
    completion = {
      menu = {
        auto_show = true,
      },
    },
  },
  completion = {
    menu = {
      border = 'single',
      draw = {
        columns = { { 'kind_icon' }, { 'label', gap = 1 } },
        components = {
          label = {
            text = function(ctx)
              return require('colorful-menu').blink_components_text(ctx)
            end,
            highlight = function(ctx)
              return require('colorful-menu').blink_components_highlight(ctx)
            end,
          },
        },
      },
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 500,
    },
  },
  keymap = {
    ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
    ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
  },
}
