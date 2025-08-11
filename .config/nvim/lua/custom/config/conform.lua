require('conform').setup {
  notify_on_error = true,
  format_after_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return {
      timeout_ms = 5000,
      lsp_format = 'fallback',
    }
  end,
  formatters_by_ft = {
    lua = { 'stylua' },
    cpp = function()
      if vim.fn.executable("lcg-clang-format-8.0.0")  == 1 then
        return { 'lcg_clang_format' }
      else
        return { 'clang-format' }
      end
    end,
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
    ruff_fix = {
      command = 'ruff',
      args = { 'check', '--select', 'I', '--fix', '--stdin-filename', '$FILENAME', '-' },
      stdin = true,
    },
    lcg_clang_format = { command = 'lcg-clang-format-8.0.0', args = { '$FILENAME' } }
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
