vim.pack.add({
    { src = 'https://github.com/kouovo/vpack.nvim' }
})

require("vpack").setup({
  window = {
    border = "rounded",
    width = 0.8,
    height = 0.8,
  },
  log = {
    path = vim.fs.joinpath(vim.fn.stdpath("log"), "nvim-pack.log"),
    border = "rounded",
    width = 0.8,
    height = 0.6,
  },
})
