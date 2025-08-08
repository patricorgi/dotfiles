local custom_utils = require 'custom.utils'
return {
  {
    'kaarmu/typst.vim',
    ft = { 'typst' },
    init = function()
      vim.g.typst_pdf_viewer = '/Applications/sioyek.app'
      vim.keymap.set('n', '<leader>tw', '<cmd>TypstWatch<cr>', { desc = 'Start Typst Watch' })
    end,
  },
  {
    'al-kot/typst-preview.nvim',
    cond = custom_utils.is_mac(),
    config = function(opts)
      local preview = require 'typst-preview'
      preview.setup(opts)
      vim.keymap.set('n', '<leader>ts', function()
        require('typst-preview').start()
      end, { desc = 'Start Typst preview' })

      vim.keymap.set('n', '<leader>tq', function()
        require('typst-preview').stop()
      end, { desc = 'Stop Typst preview' })

      vim.keymap.set('n', '<leader>tn', function()
        require('typst-preview').next_page()
      end, { desc = 'Next page' })

      vim.keymap.set('n', 'J', function()
        require('typst-preview').next_page()
      end, { desc = 'Next page' })

      vim.keymap.set('n', '<leader>tp', function()
        require('typst-preview').prev_page()
      end, { desc = 'Previous page' })

      vim.keymap.set('n', 'K', function()
        require('typst-preview').prev_page()
      end, { desc = 'Previous page' })

      vim.keymap.set('n', '<leader>tr', function()
        require('typst-preview').refresh()
      end, { desc = 'Refresh preview' })

      vim.keymap.set('n', '<leader>tgg', function()
        require('typst-preview').first_page()
      end, { desc = 'First page' })

      vim.keymap.set('n', '<leader>tG', function()
        require('typst-preview').last_page()
      end, { desc = 'Last page' })
    end,
  },
}
