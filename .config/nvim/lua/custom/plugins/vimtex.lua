return {
  'lervag/vimtex',
  ft = { 'tex' },
  init = function()
    vim.g.vimtex_view_method = 'sioyek'
    vim.g.vimtex_context_pdf_viewer = 'sioyek'
    -- vim.g.vimtex_quickfix_mode = 0
    vim.g.vimtex_log_ignore = {
      'Underfull',
      'Overfull',
      'specifier changed to',
      'Token not allowed in a PDF string',
    }
    vim.g.vimtex_quickfix_ignore_filters = {
      'Underfull',
      'Overfull',
      'specifier changed to',
      'Token not allowed in a PDF string',
      'LaTeX Warning: Float too large for page',
      'contains only floats',
    }
    vim.g.vimtex_compiler_latexmk = {
      build_dir = '.out',
      options = {
        '-shell-escape',
        '-verbose',
        '-file-line-error',
        '-interaction=nonstopmode',
        '-synctex=1',
      },
    }
    vim.cmd [[
  :autocmd BufNewFile,BufRead *.tex VimtexCompile
]]
  end,
}
