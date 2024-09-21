return {
  'kaarmu/typst.vim',
  ft = 'typst',
  lazy = false,
  init = function()
    vim.g.typst_pdf_viewer = "/Applications/sioyek.app"
  end
}
