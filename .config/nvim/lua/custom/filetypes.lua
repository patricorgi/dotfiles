vim.filetype.add {
  extension = {
    qmt = 'qmt',
    ipynb = 'ipynb',
    ent = 'xml',
    h = function(_, bufnr)
      local first_line = vim.api.nvim_buf_get_lines(bufnr, 1, 2, false)[1] or ''
      if first_line:match 'NVIDIA Corporation' then
        return 'cuda'
      end
      return 'cpp'
    end,
  },
  filename = {
    ['Snakefile'] = 'snakemake',
  },
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'help',
  callback = function()
    vim.keymap.set('n', 'q', '<CMD>quit<CR>', { buffer = true, silent = true })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'dap-float',
  callback = function()
    vim.keymap.set('n', 'q', '<CMD>quit<CR>', { buffer = true, silent = true })
  end,
})
