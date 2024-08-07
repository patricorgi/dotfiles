return { -- Collection of various small independent plugins/modules
  'echasnovski/mini.nvim',
  event = 'VeryLazy',
  dependencies = {
    {
      'echasnovski/mini.icons',
      opts = function(_, opts)
        if vim.g.icons_enabled == false then
          opts.style = 'ascii'
        end
        return opts
      end,
      lazy = true,
      specs = {
        { 'nvim-tree/nvim-web-devicons', enabled = false, optional = true },
      },
      init = function()
        package.preload['nvim-web-devicons'] = function()
          require('mini.icons').mock_nvim_web_devicons()
          return package.loaded['nvim-web-devicons']
        end
      end,
      config = function()
        require('mini.icons').setup { style = 'glyph' }
      end,
    },
    {
      'echasnovski/mini.ai',
      event = 'User AstroFile',
      opts = {},
      specs = {
        {
          'catppuccin',
          optional = true,
          opts = { integrations = { mini = true } },
        },
      },
    },
  },
  config = function()
    require('mini.icons').setup {}
    require('mini.ai').setup()
  end,
}
