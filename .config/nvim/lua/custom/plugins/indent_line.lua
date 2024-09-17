return {
  'lukas-reineke/indent-blankline.nvim',
  keys = {
    'j',
    'k',
  },
  enabled = function()
    return vim.bo.filetype ~= 'bigfile'
  end,
  -- Enable `lukas-reineke/indent-blankline.nvim`
  -- See `:help ibl`
  main = 'ibl',
  opts = {
    indent = { char = ' ' },
    scope = {
      char = '┋',
      highlight = 'Comment',
      show_start = false,
      show_end = false,
    },
  },
}
