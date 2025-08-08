if true then
  return {}
end
-- change, delete surrounds
return {
  'kylechui/nvim-surround',
  enabled = false,
  version = '*', -- Use for stability; omit to use `main` branch for the latest features
  event = {
    'InsertEnter',
  },
  keys = {
    'c',
    'd',
    'y',
  },
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
