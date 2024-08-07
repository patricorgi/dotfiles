return { -- Useful plugin to show you pending keybinds.
  'folke/which-key.nvim',
  event = 'VimEnter', -- Sets the loading event to 'VimEnter'
  config = function() -- This is the function that runs, AFTER loading
    require('which-key').setup {
      ---@param ctx { mode: string, operator: string }
      defer = function(ctx)
        if vim.list_contains({ 'd', 'y' }, ctx.operator) then
          return true
        end
        return vim.list_contains({ 'v', '<C-V>', 'V' }, ctx.mode)
      end,
      preset = 'helix',
      icons = {
        colors = true,
        keys = {
          Up = '􀄨 ',
          Down = '􀄩 ',
          Left = '􀄪 ',
          Right = '􀄫 ',
          C = '􀆍 ',
          M = '􀆕 ',
          S = '􀆝 ',
          CR = '􀅇 ',
          Esc = '􀆧 ',
          ScrollWheelDown = '󱕐 ',
          ScrollWheelUp = '󱕑 ',
          NL = '􀅇 ',
          BS = '􁂉 ',
          Space = '􁁺 ',
          Tab = '􀅂 ',
        },
      },
    }

    -- Document existing key chains
    require('which-key').add {
      { '<leader>g', group = 'Git' },
      { '<leader>b', group = 'Buffer', mode = 'n', icon = ' ' },
      { '<leader>l', group = 'Lsp', mode = 'n', icon = '󰿘 ' },
      { '<leader>o', group = 'Overseer tasks', mode = 'n', icon = '󰑮 ' },
      { '<leader>f', group = 'Find', mode = 'n' },
      { '<leader>s', group = 'Search', mode = 'n' },
      { '<leader>x', group = 'Trouble', mode = 'n', icon = ' ' },
      { '<leader>t', group = 'Toggle' },
      { '<leader>h', group = 'Git Hunk', mode = { 'n', 'v' } },
    }
  end,
}
