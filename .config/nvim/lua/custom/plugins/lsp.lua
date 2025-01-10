local pip_args
if vim.startswith(vim.fn.hostname(), 'n819') then
  pip_args = { '--proxy', 'http://lbproxy:8080' } -- need LbEnv
else
  pip_args = {}
end

return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPost', 'BufNewFile' },
    cmd = { 'LspInfo', 'LspInstall', 'LspUninstall' },
    dependencies = {
      {
        'williamboman/mason.nvim',
        event = { 'VimEnter' },
        opts = {
          pip = {
            upgrade_pip = false,
            install_args = pip_args,
          },
          ui = {
            border = 'single',
            width = 0.7,
            height = 0.7,
          },
        },
      },
      { 'rmagatti/goto-preview', keys = { 'gp', 'gP' }, opts = {} },
    },
    config = function()
      require 'custom.config.lsp'
    end,
  },
}
