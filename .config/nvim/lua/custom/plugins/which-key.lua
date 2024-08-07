return {
  'folke/which-key.nvim',
  event = 'VimEnter',
  config = function()
    ---@diagnostic disable-next-line: missing-fields
    require('which-key').setup {
      ---@param ctx { mode: string, operator: string }
      defer = function(ctx)
        if vim.list_contains({ 'd', 'y' }, ctx.operator) then
          return true
        end
        return vim.list_contains({ 'v', '<C-V>', 'V' }, ctx.mode)
      end,
      -- preset = 'helix',
      icons = {
        colors = true,
        keys = {
          Up = '􀄨',
          Down = '􀄩',
          Left = '􀄪',
          Right = '􀄫',
          C = '􀆍',
          M = '􀆕',
          S = '􀆝',
          CR = '􀅇',
          Esc = '􀆧',
          ScrollWheelDown = '󱕐',
          ScrollWheelUp = '󱕑',
          NL = '􀅇',
          BS = '􁂉',
          Space = '󱁐',
          Tab = '􀅂',
        },
      },
    }

    -- Document existing key chains
    require('which-key').add {
      { '<leader>a', group = 'Avante', icon = '󰚩' },
      { '<leader>d', group = 'DAP', icon = '' },
      { '<leader>D', group = 'DiffView', icon = '' },
      { '<leader>g', group = 'Git', icon = '' },
      { '<leader>l', group = 'Lsp', mode = 'n', icon = '' },
      { '<leader>r', group = 'Overseer tasks', mode = 'n', icon = '󰑮' },
      { '<leader>f', group = 'Find', mode = 'n' },
      { '<leader>t', group = 'Toggle' },
      { '<leader>h', group = 'Git Hunk', mode = { 'n', 'v' } },
    }
  end,
}
