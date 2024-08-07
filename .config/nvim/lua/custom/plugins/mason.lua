local pip_args

if vim.startswith(vim.fn.hostname(), 'n819') then
  pip_args = { '--proxy', 'http://lbproxy:8080' }
else
  pip_args = {}
end
return {
  'williamboman/mason.nvim',
  event = 'VeryLazy',
  opts = {
    pip = {
      ---@since 1.0.0
      -- Whether to upgrade pip to the latest version in the virtual environment before installing packages.
      upgrade_pip = false,

      ---@since 1.0.0
      -- These args will be added to `pip install` calls. Note that setting extra args might impact intended behavior
      -- and is not recommended.
      --
      -- Example: { "--proxy", "https://proxyserver" }
      install_args = pip_args,
    },
  },
}
