return {
  'yetone/avante.nvim',
  cmd = { 'AvanteChat', 'AvanteAsk' },
  keys = { '<leader>aa', '<leader>af' },
  version = '*',
  opts = { provider = 'openai', file_selector = { provider = 'snacks' } },
  build = 'make',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'zbirenbaum/copilot.lua',
    'echasnovski/mini.nvim',
    'MeanderingProgrammer/render-markdown.nvim',
  },
}
