return {
  cmd = { 'texlab' },
  root_markers = { '.git', '.latexmkrc', 'latexmkrc', '.texlabroot', 'texlabroot', 'Tectonic.toml' },
  settings = {
    texlab = {
      diagnostics = {
        ignoredPatterns = {
          'Overfull',
          'Underfull',
          'Package hyperref Warning',
          'Float too large for page',
          'contains only floats',
        },
      },
    },
  },
  filetypes = { 'tex', 'plaintex', 'bib' },
}
