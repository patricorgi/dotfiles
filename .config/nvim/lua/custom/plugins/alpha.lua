local ascii_arts = require 'custom.ui.ascii_arts'
return {
  'goolord/alpha-nvim',
  config = function()
    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.startify'
    math.randomseed(os.time())
    dashboard.section.header.val = ascii_arts[math.random(1, #ascii_arts)]
    dashboard.section.header.opts = {
      -- position = 'center',
      hl = 'SpecialComment',
    }
    alpha.setup(dashboard.opts)
  end,
}
