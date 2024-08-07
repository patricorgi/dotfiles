return {
  'Bekaboo/dropbar.nvim',
  event = 'VeryLazy',
  opts = {
    sources = {
      path = {
        modified = function(sym)
          return sym:merge {
            name = sym.name .. ' 􀴥 ',
            -- icon = ' ',
            -- name_hl = 'DiffAdded',
            -- icon_hl = 'DiffAdded',
            -- ...
          }
        end,
      },
    },
  },
}
