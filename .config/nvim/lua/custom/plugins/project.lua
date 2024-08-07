return {
  'jay-babu/project.nvim',
  main = 'project_nvim',
  init = function()
    vim.keymap.set('n', '<Leader>fP', '<cmd>Telescope projects<cr>', { desc = 'Telescope projects' })
  end,
  event = 'VeryLazy',
  opts = {
    ignore_lsp = { 'lua_ls' },
    detection_methods = {
      'pattern',
      'lsp',
    },
    patterns = { '*.code-workspace', 'Makefile', 'pyrightconfig.json' },
  },
  specs = {
    {
      'nvim-telescope/telescope.nvim',
      optional = true,
      dependencies = { 'jay-babu/project.nvim' },
      opts = function()
        require('telescope').load_extension 'projects'
      end,
    },
  },
}
