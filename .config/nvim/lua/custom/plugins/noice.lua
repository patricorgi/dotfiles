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
        enabled = true,
      },
      popupmenu = {
        enabled = false,
      },
      lsp = {
        signature = {
          enabled = false,
        },
        progress = {
          enabled = true,
        },
        hover = {
          enabled = false,
        },
      },
    }
  end,
}
