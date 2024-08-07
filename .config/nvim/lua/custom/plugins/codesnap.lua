return {
  'mistricky/codesnap.nvim',
  build = 'make',
  cmd = {
    'CodeSnap',
    'CodeSnapSave',
    'CodeSnapASCII',
    'CodeSnapHighlight',
    'CodeSnapSaveHighlight',
  },
  config = function()
    require('codesnap').setup {
      watermark = '',
      bg_theme = 'summer',
    }
  end,
}
