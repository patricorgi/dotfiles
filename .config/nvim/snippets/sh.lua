local ls = require 'luasnip'
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
-- local sn = ls.snippet_node
-- local isn = ls.indent_snippet_node
local fmt = require('luasnip.extras.fmt').fmt
-- local types = require "luasnip.util.types"
ls.add_snippets('sh', {
  s(
    'notification',
    fmt(
      [[
osascript -e 'display notification "{}" with title "{}"'
    ]],
      { i(2), i(1) }
    )
  ),
  s('shebang', t { '#!/bin/bash', '', '' }),
  s(
    'arg1',
    fmt(
      [[
if [ ! $# -gt 0 ]; then
  echo "No argument provided"
  exit 1
fi
      ]],
      {}
    )
  ),
})
