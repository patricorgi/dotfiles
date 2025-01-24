return {
  'saghen/blink.cmp',
  event = { 'BufReadPost', 'BufNewFile' },
  version = '1.*',
  dependencies = {
    'xzbdmw/colorful-menu.nvim',
    config = function()
      require('colorful-menu').setup {
        ls = {
          lua_ls = { arguments_hl = '@comment' },
          clangd = {
            extra_info_hl = '@comment',
          },
          basedpyright = {
            extra_info_hl = '@comment',
          },
          fallback = true,
        },
        fallback_highlight = '@variable',
        max_width = 60,
      }
    end,
  },
  config = function()
    require 'custom.config.completion'
  end,
}
