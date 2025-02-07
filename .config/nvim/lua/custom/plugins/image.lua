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
  {
    '3rd/image.nvim',
    enabled = false,
    -- enabled = custom_utils.is_mac(),
    event = {
      'BufReadPre ' .. vim.fn.expand '~' .. '/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault/*.md',
      'BufNewFile ' .. vim.fn.expand '~' .. '/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault/*.md',
    },
    dependencies = {
      {
        'vhyrro/luarocks.nvim',
        enabled = false,
        -- enabled = custom_utils.is_mac(),
        priority = 1001,
        opts = { rocks = { 'magick' } },
      },
    },
    config = function()
      require('image').setup {
        backend = 'kitty',
        kitty_method = 'normal',
        integrations = {
          markdown = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = true,
            only_render_image_at_cursor = true,
            filetypes = { 'markdown', 'vimwiki' },
            resolve_image_path = function(document_path, image_path, fallback)
              local working_dir = vim.fn.getcwd()
              if working_dir:find(vim.fn.expand '~' .. '/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault') then
                return working_dir .. '/' .. image_path
              end
              return fallback(document_path, image_path)
            end,
          },
          html = {
            enabled = true,
          },
          css = {
            enabled = true,
          },
        },
        max_width = nil,
        max_height = nil,
        max_width_window_percentage = nil,
        max_height_window_percentage = 40,
        window_overlap_clear_enabled = false,
        window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', '' },
        editor_only_render_when_focused = true,
        tmux_show_only_in_active_window = true,
        hijack_file_patterns = { '*.png', '*.jpg', '*.jpeg', '*.gif', '*.webp', '*.avif' },
      }
    end,
  },
}
