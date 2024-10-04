local palette = require('catppuccin.palettes').get_palette 'mocha'
return {
  'shellRaining/hlchunk.nvim',
  enabled = function()
    return vim.bo.filetype ~= 'bigfile'
  end,
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    require('hlchunk').setup {
      chunk = {
        enable = true,
      },
      indent = {
        enable = vim.bo.filetype == 'python',
      },
      line_num = {
        enable = true,
        style = palette.yellow,
      },
    }
  end,
}
