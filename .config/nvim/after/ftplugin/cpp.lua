vim.lsp.start {
  name = 'clangd',
  capabilities = {
    textDocument = {
      completion = {
        editsNearCursor = true,
      },
    },
    offsetEncoding = { 'utf-8', 'utf-16' },
  },
  -- cmd = { 'clangd', '--malloc-trim' },
  cmd = { 'clangd' },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
  root_markers = {
    '.clangd',
    '.clang-tidy',
    '.clang-format',
    'compile_commands.json',
    'compile_flags.txt',
    'configure.ac', -- AutoTools
  },
  single_file_support = true,
}
