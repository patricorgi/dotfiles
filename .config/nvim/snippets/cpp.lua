local ls = require 'luasnip'
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local fmt = require('luasnip.extras.fmt').fmt
local rep = require('luasnip.extras').rep
local types = require 'luasnip.util.types'

ls.add_snippets('cpp', {
  s(
    '#if',
    c(1, {
      fmt(
        [[
      #ifdef USE_DD4HEP
      {}
      #endif
      ]],
        { i(1) }
      ),
      fmt(
        [[
      #ifdef USE_DD4HEP
      {}
      #else
      {}
      #endif
      ]],
        { i(1), i(2) }
      ),
    })
  ),
  s(
    'info',
    fmt(
      [[
      info() << {} << endmsg;
      ]],
      { i(1) }
    )
  ),
  s(
    'warning',
    fmt(
      [[
      warning() << {} << endmsg;
      ]],
      { i(1) }
    )
  ),
  s(
    'error',
    fmt(
      [[
      error() << {} << endmsg;
      ]],
      { i(1) }
    )
  ),
  s(
    'std::cout',
    fmt(
      [[
      std::cout << {} << '\n';
      ]],
      { i(1) }
    )
  ),
  s(
    'pvar',
    fmt(
      [[
    "\t{}: " << {} <<
    ]],
      { i(1), rep(1) }
    )
  ),
  s(
    'gaudiprop',
    fmt(
      [[
      Gaudi::Property<{}> {}{{this, "{}", {}, "{}"}};
      ]],
      { i(1, 'type'), i(2, 'name'), i(3, 'option'), i(4, 'default'), i(5, 'description') }
    )
  ),
})
