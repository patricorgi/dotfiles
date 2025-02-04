return {
  'yetone/avante.nvim',
  cmd = { 'AvanteChat', 'AvanteAsk' },
  keys = { '<leader>aa', '<leader>af' },
  version = false,
  opts = { provider = 'openai', file_selector = { provider = 'telescope' } },
  build = 'make',
  dependencies = {
    'stevearc/dressing.nvim',
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'zbirenbaum/copilot.lua',
    'echasnovski/mini.nvim',
    {
      'MeanderingProgrammer/render-markdown.nvim',
      opts = { file_types = { 'markdown', 'Avante' } },
      ft = { 'markdown', 'Avante' },
    },
  },
}
