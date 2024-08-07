return {
  {
    'altermo/ultimate-autopair.nvim',
    event = { 'InsertEnter' },
    branch = 'v0.6', --recommended as each new version will have breaking changes
    opts = {
      pair_cmap = false,
      tabout = {
        enable = true,
        map = '<C-q>',
        cmap = '<C-q>',
        hopout = true,
      },
    },
  },
}
