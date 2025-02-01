return {
  {
    'altermo/ultimate-autopair.nvim',
    event = { 'InsertEnter' },
    branch = 'v0.6', --recommended as each new version will have breaking changes
    opts = {
      pair_cmap = false,
      tabout = {
        enable = true,
        map = '<C-l>',
        cmap = '<C-l>',
      },
    },
  },
  {
    {
      'abecodes/tabout.nvim',
      opt = true, -- Set this to true if the plugin is optional
      event = 'InsertCharPre', -- Set the event to 'InsertCharPre' for better compatibility
      priority = 1000,
      config = function()
        require('tabout').setup {
          tabkey = '<Tab>', -- key to trigger tabout, set to an empty string to disable
          backwards_tabkey = '<S-Tab>', -- key to trigger backwards tabout, set to an empty string to disable
          act_as_tab = true, -- shift content if tab out is not possible
          act_as_shift_tab = false, -- reverse shift content if tab out is not possible (if your keyboard/terminal supports <S-Tab>)
          default_tab = '<C-t>', -- shift default action (only at the beginning of a line, otherwise <TAB> is used)
          default_shift_tab = '<C-d>', -- reverse shift default action,
          enable_backwards = true, -- well ...
          completion = false, -- if the tabkey is used in a completion pum
          tabouts = {
            { open = "'", close = "'" },
            { open = '"', close = '"' },
            { open = '`', close = '`' },
            { open = '(', close = ')' },
            { open = '[', close = ']' },
            { open = '{', close = '}' },
          },
          ignore_beginning = true, --[[ if the cursor is at the beginning of a filled element it will rather tab out than shift the content ]]
          exclude = {}, -- tabout will ignore these filetypes
        }
      end,
    },
  },
}
