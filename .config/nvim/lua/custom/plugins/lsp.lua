local pip_args

if vim.startswith(vim.fn.hostname(), 'n819') then
  pip_args = { '--proxy', 'http://lbproxy:8080' }
else
  pip_args = {}
end
return {
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      {
        'williamboman/mason.nvim',
        event = 'VeryLazy',
        opts = {
          pip = {
            ---@since 1.0.0
            -- Whether to upgrade pip to the latest version in the virtual environment before installing packages.
            upgrade_pip = false,

            ---@since 1.0.0
            -- These args will be added to `pip install` calls. Note that setting extra args might impact intended behavior
            -- and is not recommended.
            --
            -- Example: { "--proxy", "https://proxyserver" }
            install_args = pip_args,
          },
        },
      }, -- NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim',
      -- { 'WhoIsSethDaniel/mason-tool-installer.nvim', event = 'VeryLazy' },
      -- Allows extra capabilities provided by nvim-cmp
      { 'hrsh7th/cmp-nvim-lsp', event = 'InsertEnter' },
    },
    config = function()
      require 'custom.config.lsp'
    end,
    cmd = { 'LspInfo', 'LspInstall', 'LspUninstall' },
  },
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true },
  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre', "InsertEnter" },
    cmd = { 'ConformInfo', "FormatEnable", "FormatDisable" },
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
    ft = { 'python', 'cpp' },
    main = 'lsp_signature',
    opts = {
      hint_enable = false, -- disable hints as it will crash in some terminal
    },
    specs = {
      {
        'folke/noice.nvim',
        optional = true,
        opts = {
          lsp = {
            signature = { enabled = false },
            hover = { enabled = false },
          },
        },
      },
    },
  },
}
