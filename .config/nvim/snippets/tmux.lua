local ls = require "luasnip"
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
-- local sn = ls.snippet_node
-- local isn = ls.indent_snippet_node
local fmt = require("luasnip.extras.fmt").fmt
-- local types = require "luasnip.util.types"
ls.add_snippets("tmux", {
  s(
    "s|",
    fmt(
      [[
s|{}|{}|;
      ]],
      {i(1), i(2)}
    )
  ),
})

