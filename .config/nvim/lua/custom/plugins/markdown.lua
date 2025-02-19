return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown', 'Avante' },
    config = function()
      require 'custom.config.render-markdown'
    end,
  },
  {
    'bullets-vim/bullets.vim',
    ft = { 'markdown' },
  },
}
