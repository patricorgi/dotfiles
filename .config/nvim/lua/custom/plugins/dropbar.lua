return {
  'Bekaboo/dropbar.nvim',
  event = 'VeryLazy',
  -- optional, but required for fuzzy finder support
  dependencies = {
    'nvim-telescope/telescope-fzf-native.nvim',
  },
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
