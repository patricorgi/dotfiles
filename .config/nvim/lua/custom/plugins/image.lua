local custom_utils = require 'custom.utils'
return {
  {
    'HakonHarnes/img-clip.nvim',
    enabed = custom_utils.is_mac(),
    event = {
      'BufReadPre ' .. vim.fn.expand '~' .. '/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault/*.md',
      'BufNewFile ' .. vim.fn.expand '~' .. '/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault/*.md',
    },
    opts = {
      default = {
        dir_path = './attachments',
        use_absolute_path = false,
        copy_images = true,
        prompt_for_file_name = false,
        file_name = '%y%m%d-%H%M%S',
        extension = 'avif',
        process_cmd = 'convert - -quality 75 avif:-',
      },
    },
    keys = {
      { '<leader>P', '<cmd>PasteImage<cr>', desc = 'Paste image from system clipboard' },
    },
  },
}
