---@diagnostic disable: missing-fields, duplicate-set-field
return { -- Autocompletion
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  dependencies = {
    'onsails/lspkind.nvim',
    -- Snippet Engine & its associated nvim-cmp source
    {
      'L3MON4D3/LuaSnip',
      build = (function()
        -- Build Step is needed for regex support in snippets.
        -- This step is not supported in many windows environments.
        -- Remove the below condition to re-enable on windows.
        if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
          return
        end
        return 'make install_jsregexp'
      end)(),
      dependencies = {
        {
          'rafamadriz/friendly-snippets',
          event = 'VeryLazy',
          config = function()
            require('luasnip.loaders.from_lua').load {
              paths = { '~/.config/nvim/lua/snippets' },
            }
            require('luasnip.loaders.from_vscode').lazy_load()
          end,
        },
      },
      config = function()
        local ls = require 'luasnip'
        vim.keymap.set({ 'i', 's' }, '<C-e>', function()
          if ls.choice_active() then
            ls.change_choice(1)
          end
        end)
      end,
    },
    'saadparwaiz1/cmp_luasnip',

    -- Adds other completion capabilities.
    --  nvim-cmp does not ship with all sources by default. They are split
    --  into multiple repos for maintenance purposes.
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
    local luasnip = require 'luasnip'
    luasnip.config.setup {}
    local palette = require('catppuccin.palettes').get_palette 'mocha'

    -- Styling
    vim.api.nvim_set_hl(0, 'CmpNormal', { bg = palette.surface0 })
    vim.api.nvim_set_hl(0, 'CmpNormalDoc', { bg = palette.surface1 })
    vim.api.nvim_set_hl(0, 'CmpCursorLine', { bg = palette.blue, fg = palette.base })
    vim.api.nvim_set_hl(0, 'CmpFloatBorder', { fg = palette.surface1, bg = palette.surface1 })

    local cmp = require 'cmp'
    cmp.setup {
      formatting = {
        format = require('lspkind').cmp_format(),
      },
      -- formatting = {
      --   fields = { 'kind', 'abbr', 'menu' },
      --   format = function(entry, vim_item)
      --     local kind = require('lspkind').cmp_format { mode = 'symbol_text', maxwidth = 50 }(entry, vim_item)
      --     local strings = vim.split(kind.kind, '%s', { trimempty = true })
      --     kind.kind = ' ' .. (strings[1] or '') .. ' '
      --     kind.menu = '    (' .. (strings[2] or '') .. ')'
      --     return kind
      --   end,
      -- },
      window = {
        completion = { winhighlight = 'Normal:CmpNormal,FloatBorder:CmpFloatBorder,CursorLine:CmpCursorLine,Search:None', side_padding = 1 },
        documentation = cmp.config.window.bordered { winhighlight = 'Normal:CmpNormalDoc,FloatBorder:CmpFloatBorder,CursorLine:CmpCursorLine,Search:None' },
      },
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      completion = { completeopt = 'menu,menuone,noinsert' },

      -- For an understanding of why these mappings were
      -- chosen, you will need to read `:help ins-completion`
      --
      -- No, but seriously. Please read `:help ins-completion`, it is really good!
      mapping = cmp.mapping.preset.insert {
        -- Select the next item
        ['<C-n>'] = cmp.mapping.select_next_item(),
        -- Select the previous item
        ['<C-p>'] = cmp.mapping.select_prev_item(),

        -- Scroll the documentation window back / forward
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),

        -- Accept (yes) the completion.
        --  This will auto-import if your LSP supports it.
        --  This will expand snippets if the LSP sent a snippet.
        ['<C-y>'] = cmp.mapping.confirm { select = true },

        -- If you prefer more traditional completion keymaps,
        -- you can uncomment the following lines
        --['<CR>'] = cmp.mapping.confirm { select = true },
        --['<Tab>'] = cmp.mapping.select_next_item(),
        --['<S-Tab>'] = cmp.mapping.select_prev_item(),

        -- Manually trigger a completion from nvim-cmp.
        --  Generally you don't need this, because nvim-cmp will display
        --  completions whenever it has completion options available.
        ['<C-Space>'] = cmp.mapping.complete {},

        -- Think of <c-l> as moving to the right of your snippet expansion.
        --  So if you have a snippet that's like:
        --  function $name($args)
        --    $body
        --  end
        --
        -- <c-j> will move you to the right of each of the expansion locations.
        -- <c-k> is similar, except moving you backwards.
        ['<C-j>'] = cmp.mapping(function()
          if luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          end
        end, { 'i', 's' }),
        ['<C-k>'] = cmp.mapping(function()
          if luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          end
        end, { 'i', 's' }),
        -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
        --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
      },
      sources = {
        {
          name = 'lazydev',
          -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
          group_index = 0,
        },
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'path' },
        {
          name = 'buffer',
          option = {
            get_bufnrs = function()
              return vim.api.nvim_list_bufs()
            end,
          },
        },
      },
    }
  end,
}
