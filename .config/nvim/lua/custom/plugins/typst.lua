return {
  'kaarmu/typst.vim',
  ft = { 'typst' },
  init = function()
    vim.g.typst_pdf_viewer = '/Applications/sioyek.app'
  end,
}
