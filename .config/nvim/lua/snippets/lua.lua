local ls = require 'luasnip'
local s = ls.snippet
local i = ls.insert_node
local fmt = require('luasnip.extras.fmt').fmt
ls.add_snippets('lua', {
  s(
    'nkey',
    fmt(
      [[
vim.keymap.set('n', '{}', '{}', {{ desc = '{}' }} )
    ]],
      { i(1), i(2), i(3) }
    )
  ),
})
