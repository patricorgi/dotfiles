local pip_args
local proxy = os.getenv 'PIP_PROXY'
if proxy then
  pip_args = { '--proxy', proxy }
else
  pip_args = {}
end

return {
  'williamboman/mason.nvim',
  event = { 'BufReadPost', 'BufNewFile', 'VimEnter' },
  config = function()
    require('mason').setup {
      pip = {
        upgrade_pip = false,
        install_args = pip_args,
      },
      ui = {
        border = 'single',
        width = 0.7,
        height = 0.7,
      },
    }
  end,
}
