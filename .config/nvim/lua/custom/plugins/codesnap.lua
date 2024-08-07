return {
  'mistricky/codesnap.nvim',
  build = 'make',
  event = 'VeryLazy',
  config = function()
    require('codesnap').setup {
      watermark = '',
      bg_theme = 'summer',
    }
  end,
}
