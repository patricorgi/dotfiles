local custom_utils = require 'custom.utils'

return {
  'lervag/vimtex',
  enabled = custom_utils.is_mac(),
  lazy = false,
  init = function()
    vim.g.vimtex_view_method = 'sioyek'
    -- vim.g.vimtex_quickfix_mode = 0
    vim.g.vimtex_quickfix_ignore_filters = {
      'Underfull',
      'Overfull',
      'specifier changed to',
      'Token not allowed in a PDF string',
      'LaTeX Warning: Float too large for page',
      'contains only floats',
      'LaTeX Warning: Citation',
      'Missing "author" in',
      'LaTeX Font Warning:',
      'Package option "final" no longer has any effect with minted v3+',
    }
    -- vim.api.nvim_create_autocmd('VimEnter', {
    --   callback = function()
    --     local buf_ft = vim.bo.filetype
    --     if buf_ft == 'tex' then
    --       vim.cmd 'VimtexCompile'
    --     end
    --   end,
    -- })
  end,
}
