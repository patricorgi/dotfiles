local ls = require 'luasnip'
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
-- local sn = ls.snippet_node
-- local isn = ls.indent_snippet_node
local fmt = require('luasnip.extras.fmt').fmt
-- local types = require "luasnip.util.types"

ls.add_snippets('typst', {
  s(
    'N2',
    t {
      'N#sub[2]',
    }
  ),
  s(
    'CO2',
    t {
      'CO#sub[2]',
    }
  ),
  s('side-by-side', fmt('#side-by-side(columns: ({}))[{}]', { i(1, '1fr, 1fr'), i(2) })),
  s(
    'table',
    fmt(
      [[
    #table(
      columns: ({}),
      inset: 10pt,
      align: ({}),
      {},
    )
    ]],
      {
        i(1, 'auto, auto, auto, auto'),
        i(2, 'left, left, left, left'),
        i(3, '[C1], [C2], [C3], [C4]'),
      }
    )
  ),
  s(
    'image',
    c(1, {
      fmt('#image("{}")', { i(1) }),
      fmt('#align(center)[#image("{}")]', { i(1) }),
      fmt(
        [[
#figure(
  image("{}")
  caption: [{}],
)
]],
        { i(1), i(2) }
      ),
    })
  ),
  s(
    'ftable',
    fmt(
      [[
    #figure(
      caption: [{}],
      table(
        columns: ({}),
        align: ({}),
        {},
      )
    )
    ]],
      {
        i(1),
        i(2, 'auto, auto, auto, auto'),
        i(3, 'left, left, left, left'),
        i(4, '[C1], [C2], [C3], [C4]'),
      }
    )
  ),
  s('link', fmt('#link("{}")[{}]', { i(1), i(2) })),
  s(
    'slide',
    c(1, {
      fmt(
        [[
  #slide[
    {}
  ]
        ]],
        { i(1) }
      ),
      fmt(
        [[
  #centered-slide[
    {}
  ]
        ]],
        { i(1) }
      ),
      fmt(
        [[
  #focus-slide[
    {}
  ]
        ]],
        { i(1) }
      ),
      fmt(
        [[
  #side-by-side(gutter: 10pt, columns: ({}))[
    {}
  ]
        ]],
        { i(1, '1fr, 1fr'), i(2) }
      ),
    })
  ),
  --   s(
  --     "fimage",
  --     c(1, {
  --     fmt(
  --       [[
  --   #figure(
  --     image("{}")
  --     caption: [{}],
  --   )
  --   ]],
  --       {
  --         i(1),
  --         i(2),
  --       }
  --     ),
  --     fmt(
  --       [[
  --   #figure(
  --     image("{}")
  --     caption: [{}],
  --   ) <{}>
  --   ]],
  --       {
  --         i(1),
  --         i(2),
  --         i(3),
  --       }
  --     )
  --     }),
  --   ),
  s('align', fmt('#align({})[{}]', { i(1, 'center'), i(2) })),
  s(
    'block',
    c(1, {
      fmt('#block(radius: 10pt, clip: true)[{}]', { i(1) }),
      fmt('#block(width: {}, radius: 10pt, clip: true)[{}]', { i(1), i(2) }),
    })
  ),
  s(
    'cblock',
    c(1, {
      fmt('#align(center)[#block(radius: 10, clip: true)[{}]]', { i(1) }),
      fmt('#align(center)[#block(width: {}, radius: 10, clip: true)[{}]]', { i(1), i(2) }),
    })
  ),
  s(
    'grid',
    fmt(
      [[
        #grid(
          columns: ({}),
          gutter: 10pt,
          [{}],
          [{}],
        )
      ]],
      {
        i(1, '1fr'),
        i(2),
        i(3),
      }
    )
  ),
})
