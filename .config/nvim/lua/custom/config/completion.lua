require('blink.cmp').setup {
  keymap = {
    ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
    ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
  },
  snippets = {
    preset = 'luasnip',
  },
  sources = {
    default = { 'snippets', 'lsp', 'path', 'buffer' },
    providers = {
      snippets = { score_offset = 1000 },
    },
  },
  completion = {
    keyword = {
      range = 'full',
    },
    menu = {
      border = 'single',
      draw = {
        columns = { { 'label', 'label_description', gap = 1 }, { 'kind_icon', 'kind' } },
        treesitter = { 'lsp' },
        components = {
          kind_icon = {
            highlight = function(ctx)
              local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
              return hl
            end,
          },
          kind = {
            highlight = function(ctx)
              local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
              return hl
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

local luasnip = require 'luasnip'
vim.keymap.set({ 'i', 's' }, '<Tab>', function()
  if luasnip.expand_or_locally_jumpable() then
    luasnip.expand_or_jump()
  end
end)
vim.keymap.set({ 'i', 's' }, '<S-Tab>', function()
  if luasnip.locally_jumpable(-1) then
    luasnip.jump(-1)
  end
end)
