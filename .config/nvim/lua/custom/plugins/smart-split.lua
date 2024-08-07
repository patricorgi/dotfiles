return {
  'mrjones2014/smart-splits.nvim',
  event = 'VeryLazy',
  config = function()
    local smart_splits = require 'smart-splits'
    smart_splits.setup {
      resize_mode = {
        silent = true,
        hooks = {
          on_enter = function()
            vim.notify 'Entering resize mode'
          end,
          on_leave = function()
            vim.notify 'Exiting resize mode, bye'
          end,
        },
      },
    }
    vim.keymap.set('n', '<M-Up>', function()
      smart_splits.resize_up(5)
    end, {})
    vim.keymap.set('n', '<M-Down>', function()
      smart_splits.resize_down(5)
    end, {})
    vim.keymap.set('n', '<M-Right>', function()
      smart_splits.resize_right(5)
    end, {})
    vim.keymap.set('n', '<M-Left>', function()
      smart_splits.resize_left(5)
    end, {})
  end,
}
