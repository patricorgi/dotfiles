local pip_args

if vim.startswith(vim.fn.hostname(), 'n819') then
  pip_args = { '--proxy', 'http://lbproxy:8080' }
else
  pip_args = {}
end
return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPost', 'BufNewFile' },
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
      -- { 'hrsh7th/cmp-nvim-lsp', event = 'InsertEnter' },
    },
    config = function()
      require 'custom.config.lsp'
    end,
    cmd = { 'LspInfo', 'LspInstall', 'LspUninstall' },
  },
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true },
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
  {
    'ray-x/lsp_signature.nvim',
    ft = { 'python', 'cpp', 'lua' },
    main = 'lsp_signature',
    opts = {
      hint_enable = false, -- disable hints as it will crash in some terminal
    },
  },
}
