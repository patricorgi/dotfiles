return {
  'catppuccin/nvim',
  priority = 1000, -- Make sure to load this before all the other start plugins.
  init = function()
    vim.cmd.colorscheme 'catppuccin-mocha'
    vim.cmd.hi 'Comment gui=none'
  end,
  config = function()
    require('catppuccin').setup {
      transparent_background = true,
      term_colors = true,
      integrations = {
        aerial = true,
        diffview = true,
        mini = {
          enabled = true,
          indentscope_color = 'sky',
        },
        noice = true,
        -- overseer = true,
        telescope = {
          enabled = true,
          -- style = "nvchad",
        },
        nvimtree = false,
        neotree = true,
        which_key = true,
        treesitter = true,
        notify = true,
        gitsigns = true,
        flash = true,
        blink_cmp = true,
        mason = true,
        snacks = true,
      },
      highlight_overrides = {
        mocha = function(mocha)
          return {
            CursorLineNr = { fg = mocha.yellow },
            TelescopeSelection = { bg = mocha.surface0 },
            TelescopeSelectionCaret = { fg = mocha.yellow, bg = mocha.surface0 },
            TelescopePromptPrefix = { fg = mocha.yellow },
          }
        end,
      },
    }
  end,
}
