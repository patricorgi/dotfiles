-- change, delete surrounds
return {
  'kylechui/nvim-surround',
  version = '*', -- Use for stability; omit to use `main` branch for the latest features
  event = 'VeryLazy',
  config = function()
    require('nvim-surround').setup {
      surrounds = {
        ['q'] = {
          add = { '"', '"' },
          find = function()
            return require('nvim-surround.config').get_selection { motion = 'a"' }
          end,
          delete = '^(.)().-(.)()$',
        },
      },
    }
  end,
}
