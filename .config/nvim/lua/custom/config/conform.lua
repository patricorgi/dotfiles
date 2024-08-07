require('conform').setup {
  notify_on_error = true,
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return {
      timeout_ms = 1000,
      lsp_format = 'fallback',
    }
  end,
  formatters_by_ft = {
    lua = { 'stylua' },
    cpp = { 'clang-format' },
    python = { 'yapf', 'isort' },
    sh = { 'shfmt' },
    snakemake = { 'snakefmt' },
    markdown = { 'prettierd', 'cbfmt' },
    typst = { 'typstyle' },
    nix = { 'nixfmt' },
    json = { 'prettierd' },
    toml = { 'taplo' },
    tex = { 'tex-fmt' },
  },
  formatters = {
    cbfmt = { command = 'cbfmt', args = { '-w', '--config', vim.fn.expand '~' .. '/.config/cbfmt.toml', '$FILENAME' } },
    taplo = { command = 'taplo', args = { 'fmt', '--option', 'indent_tables=false', '-' } },
  },
}

vim.api.nvim_create_user_command('ConformDisable', function(args)
  if args.bang then
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, {
  desc = 'Disable autoformat-on-save',
  bang = true,
})
vim.api.nvim_create_user_command('ConformEnable', function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {
  desc = 'Re-enable autoformat-on-save',
})
