return {
  'folke/edgy.nvim',
  event = 'VeryLazy',
  keys = {
    n = {
      ['<leader>B'] = {
        function()
          require('edgy').toggle()
        end,
        desc = 'Toggle Sidebars',
      },
    },
  },
  specs = {
    {
      'nvim-neo-tree/neo-tree.nvim',
      optional = true,
      opts = {
        source_selector = {
          winbar = true,
          statusline = false,
        },
        open_files_do_not_replace_types = { 'terminal', 'trouble', 'qf', 'edgy', 'telescopeprompt', 'OverseerList' },
      },
    },
  },
  opts = {
    animate = {
      enabled = false,
    },
    exit_when_last = true,
    bottom = {
      { ft = 'qf', title = 'QuickFix' },
      { ft = 'terminal', title = 'Terminal' },
      {
        ft = '',
        title = 'Terminal',
        filter = function(buf)
          return vim.bo[buf].buftype == 'terminal'
        end,
      },
      {
        ft = 'help',
        size = { height = 0.8 },
        -- don't open help files in edgy that we're editing
        filter = function(buf)
          return vim.bo[buf].buftype == 'help'
        end,
      },
    },
    left = {
      {
        title = 'Files',
        ft = 'neo-tree',
        filter = function(buf)
          return vim.b[buf].neo_tree_source == 'filesystem'
        end,
        pinned = true,
        open = 'Neotree position=left filesystem',
        size = { height = 0.5 },
      },
      {
        ft = 'aerial',
        title = 'Symbol Outline',
        open = function()
          require('aerial').open()
        end,
        size = { height = 0.3 },
      },
    },
    right = {
      { title = 'TaskList', ft = 'OverseerList', open = 'OverseerToggle' },
      'trouble',
    },
    icons = {
      closed = '›',
      open = '',
    },
  },
}
