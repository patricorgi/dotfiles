return {
  'folke/flash.nvim',
  enabled = false,
  opts = {
    jump = {
      autojump = true,
    },
    modes = {
      char = {
        autohide = true,
      },
    },
    exclude = {
      'notify',
      'cmp_menu',
      'noice',
      'lazy',
      'flash_prompt',
      function(win)
        -- exclude non-focusable windows
        return not vim.api.nvim_win_get_config(win).focusable
      end,
    },
    prompt = {
      prefix = { { '', 'FlashPromptIcon' } },
    },
  },
  keys = {
    {
      'ss',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').jump()
      end,
      desc = 'Flash Jump',
    },
    {
      'SS',
      mode = { 'n', 'o', 'x' },
      function()
        require('flash').treesitter_search()
      end,
      desc = 'Flash Treesitter Search',
    },
  },
}
