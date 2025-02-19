local custom_utils = require('custom.utils')

return {
  'lervag/vimtex',
  enabled = custom_utils.is_mac(),
  ft = { 'tex' },
  lazy = false,
  init = function()
    vim.g.vimtex_view_method = 'sioyek'
    vim.g.vimtex_context_pdf_viewer = 'sioyek'
    -- vim.g.vimtex_view_sioyek_options = '--nofocus'
    vim.g.vimtex_quickfix_mode = 0
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
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VimtexEventViewReverse',
      callback = function()
        vim.system { 'open', '/Applications/kitty.app' }
      end,
    })
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VimtexEventQuit',
      callback = function()
        vim.system { 'open', '/Applications/kitty.app' }
      end,
    })
    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function()
        local buf_ft = vim.bo.filetype
        if buf_ft == 'tex' then
          vim.cmd 'VimtexCompile'
        end
      end,
    })
  end,
}
