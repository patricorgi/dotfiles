require('blink.cmp').setup {
  keymap = {
    ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
    ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
  },
  sources = {
    default = { 'snippets', 'lsp', 'path', 'buffer' },
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
    keyword = {
      range = 'full',
    },
    menu = {
      border = 'single',
      draw = {
        treesitter = { 'lsp' },
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
      scrollbar = false,
    },
    documentation = {
      window = { border = 'single', scrollbar = false },
      auto_show = true,
      auto_show_delay_ms = 500,
    },
  },
  signature = {
    enabled = true,
    window = { border = 'single' },
  },
  appearance = {
    nerd_font_variant = 'normal',
  },
}
