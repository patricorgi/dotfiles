require('conform').setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    -- Disable "format_on_save lsp_fallback" for languages that don't
    -- have a well standardized coding style. You can add additional
    -- languages here or re-enable it for the disabled ones.
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
  },
  formatters = {
    cbfmt = { command = 'cbfmt', args = { '-w', '--config', vim.fn.expand '~' .. '/.config/cbfmt.toml', '$FILENAME' } },
    yapf = { command = 'yapf' },
  },
}
