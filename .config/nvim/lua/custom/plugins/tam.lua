return {
  'otavioschwanck/tmux-awesome-manager.nvim',
  event = 'VeryLazy',
  config = function ()
   require('custom.config.tam')
  end
}
