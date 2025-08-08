return {
  'stevearc/conform.nvim',
  init = function()
    vim.g.disable_autoformat = false
    vim.keymap.set('n', '<leader>tf', function()
      if vim.g.disable_autoformat then
        vim.g.disable_autoformat = false
        vim.notify('Autoformat is enabled', vim.log.levels.INFO)
      else
        vim.g.disable_autoformat = true
        vim.notify('Autoformat is disabled', vim.log.levels.WARN)
      end
    end, { desc = 'Toggle autoformatting' })
  end,
  event = { 'BufWritePre', 'InsertEnter' },
  cmd = { 'ConformInfo', 'FormatEnable', 'FormatDisable' },
  keys = {
    {
      '<leader>lf',
      function()
        require('conform').format { async = true, lsp_fallback = true }
      end,
      desc = 'Format buffer',
    },
  },
  config = function()
    require 'custom.config.conform'
  end,
}
