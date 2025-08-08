local ls = require "luasnip"
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local fmt = require("luasnip.extras.fmt").fmt
local types = require "luasnip.util.types"

vim.keymap.set({ "i", "s" }, "<A-n>", function()
  if ls.choice_active() then ls.change_choice(1) end
end, { silent = true })

ls.add_snippets("all", {
  s("p3", t "lb-conda default/2023-04-26 python3"),
})
