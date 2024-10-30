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
        event = 'VeryLazy',
        opts = {
          pip = {
            upgrade_pip = false,
            install_args = pip_args,
          },
        },
      },
      'williamboman/mason-lspconfig.nvim',
      { 'hrsh7th/cmp-nvim-lsp', event = 'InsertEnter' },
    },
    config = function()
      require 'custom.config.lsp'
    end,
  },
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre', 'InsertEnter' },
    cmd = { 'ConformInfo', 'FormatEnable', 'FormatDisable' },
    keys = {
      {
        '<leader>lf',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = 'Lsp Format buffer',
      },
    },
    config = function()
      require 'custom.config.conform'
    end,
  },
  { 'patricorgi/vim-snakemake', ft = { 'Snakefile', 'snakemake' } },
}
