---@diagnostic disable: missing-fields
return {
  'folke/noice.nvim',
  dependencies = {
    'MunifTanjim/nui.nvim',
  },
  keys = { ':', '/', '?' }, -- lazy load cmp on more keys along with insert mode
  config = function()
    require('noice').setup {
      presets = {
        command_palette = false,
      },
      messages = {
        enabled = false,
      },
      popupmenu = {
        enabled = false,
      },
      lsp = {
        signature = {
          enabled = false,
        },
        progress = {
          enabled = false,
        },
        hover = {
          enabled = false,
        },
      },
    }
  end,
}
