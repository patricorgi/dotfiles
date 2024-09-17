return {
  'otavioschwanck/tmux-awesome-manager.nvim',
  keys = {
    '<leader>sc',
    '<leader>tm',
  },
  config = function()
    require 'custom.config.tam'
  end,
}
