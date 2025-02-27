return {
  'Bekaboo/dropbar.nvim',
  enabled = false,
  event = { 'BufReadPre' },
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
