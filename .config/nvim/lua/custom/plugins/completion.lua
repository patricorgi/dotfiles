if vim.startswith(vim.fn.hostname(), 'lhcb-dev4') or vim.fn.hostname() == 'ubuntu-lhcb-devnode-02' then
  ---@diagnostic disable: missing-fields, duplicate-set-field
  return { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'onsails/lspkind.nvim',
      {
        'L3MON4D3/LuaSnip',
        event = 'InsertEnter',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        config = function()
          local ls = require 'luasnip'
          vim.keymap.set({ 'i', 's' }, '<C-e>', function()
            if ls.choice_active() then
              ls.change_choice(1)
            end
          end)
          require('luasnip.loaders.from_lua').load {
            paths = { '~/.config/nvim/lua/snippets' },
          }
          require('luasnip.loaders.from_vscode').lazy_load()
        end,
      },
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      { 'hrsh7th/cmp-buffer', lazy = true },
      {
        'hrsh7th/cmp-cmdline',
        keys = { ':', '/', '?' }, -- lazy load cmp on more keys along with insert mode
        dependencies = { 'hrsh7th/nvim-cmp' },
        opts = function()
          local cmp = require 'cmp'
          return {
            {
              type = '/',
              mapping = cmp.mapping.preset.cmdline(),
              sources = {
                { name = 'buffer' },
              },
            },
            {
              type = ':',
              mapping = cmp.mapping.preset.cmdline(),
              sources = cmp.config.sources({
                { name = 'path' },
              }, {
                {
                  name = 'cmdline',
                  option = {
                    ignore_cmds = { 'Man', '!' },
                  },
                },
              }),
            },
          }
        end,
        config = function(_, opts)
          local cmp = require 'cmp'
          vim.tbl_map(function(val)
            cmp.setup.cmdline(val.type, val)
          end, opts)
        end,
      },
    },
    config = function()
      require 'custom.config.completion'
    end,
  }
else
  return {
    {
      'saghen/blink.cmp',
      version = 'v0.*',
      -- !Important! Make sure you're using the latest release of LuaSnip
      -- `main` does not work at the moment
      dependencies = {
        'L3MON4D3/LuaSnip',
        -- dependencies = {
        --   'rafamadriz/friendly-snippets',
        -- },
        version = 'v2.*',
        config = function()
          require('luasnip.loaders.from_lua').load {
            paths = { '~/.config/nvim/lua/snippets' },
          }
          require('luasnip.loaders.from_vscode').lazy_load()
        end,
      },
      opts = {
        snippets = {
          expand = function(snippet)
            require('luasnip').lsp_expand(snippet)
          end,
          active = function(filter)
            if filter and filter.direction then
              return require('luasnip').jumpable(filter.direction)
            end
            return require('luasnip').in_snippet()
          end,
          jump = function(direction)
            require('luasnip').jump(direction)
          end,
        },
        sources = {
          default = { 'lsp', 'path', 'luasnip', 'buffer' },
        },
        completion = {
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 500,
          },
        },
        signature = {
          enabled = true,
        },
      },
    },
  }
end
