return {
  'saghen/blink.cmp',
  build = 'cargo build --release',
  config = function()
    require 'custom.config.completion'
  end,
}
