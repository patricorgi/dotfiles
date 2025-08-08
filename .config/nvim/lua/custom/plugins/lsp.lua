local pip_args
local proxy = os.getenv 'PIP_PROXY'
if proxy then
  pip_args = { '--proxy', proxy }
else
  pip_args = {}
end

return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPost', 'BufNewFile' },
    cmd = { 'LspInfo', 'LspInstall', 'LspUninstall' },
    dependencies = {
      {
        'williamboman/mason.nvim',
        event = { 'VimEnter' },
        opts = {
          pip = {
            upgrade_pip = false,
            install_args = pip_args,
          },
          ui = {
            border = 'single',
            width = 0.7,
            height = 0.7,
          },
        },
      },
    },
    config = function()
      require 'custom.config.lsp'
    end,
  },
}
