require('conform').setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    local disable_filetypes = { c = true }
    return {
      timeout_ms = 2000,
      lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
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
  },
  formatters = {
    cbfmt = { command = 'cbfmt', args = { '-w', '--config', vim.fn.expand '~' .. '/.config/cbfmt.toml', '$FILENAME' } },
    yapf = { command = 'yapf' },
    nix = { command = 'nixfmt' },
  },
}

vim.api.nvim_create_user_command('ConformDisable', function(args)
  if args.bang then
    -- FormatDisable! will disable formatting just for this buffer
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
