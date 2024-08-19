local ls = require "luasnip"
local s = ls.snippet
local i = ls.insert_node
-- local t = ls.text_node
-- local c = ls.choice_node
-- local sn = ls.snippet_node
-- local isn = ls.indent_snippet_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep
-- local types = require "luasnip.util.types"
ls.add_snippets("yaml", {
  s(
    "inv2",
    fmt(
      [[
TMath::Sqrt(TMath::Power({}_PE+{}_PE,2)-TMath::Power({}_PX+{}_PX,2)-TMath::Power({}_PY+{}_PY,2)-TMath::Power({}_PZ+{}_PZ,2))
      ]],
      {i(1), i(2), rep(1), rep(2), rep(1), rep(2), rep(1), rep(2)}
    )
  ),
})


