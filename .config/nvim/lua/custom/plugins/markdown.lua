return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown', 'Avante' },
    config = function()
      require 'custom.config.render-markdown'
    end,
  },
  {
    'AndrewRadev/switch.vim',
    config = function()
      vim.keymap.set('n', '`', function()
        vim.cmd [[Switch]]
      end, { desc = 'Switch strings' })
      vim.g.switch_custom_definitions = {
        { '> [!TODO]', '> [!WIP]', '> [!DONE]', '> [!FAIL]' },
        { 'height', 'width' },
      }
    end,
  },
  {
    'bullets-vim/bullets.vim',
    ft = { 'markdown' },
  },
  {
    'HakonHarnes/img-clip.nvim',
    ft = { 'tex', 'markdown', 'typst' },
    opts = {
      default = {
        dir_path = './attachments',
        use_absolute_path = false,
        copy_images = true,
        prompt_for_file_name = false,
        file_name = '%y%m%d-%H%M%S',
        extension = 'avif',
        process_cmd = 'magick convert - -quality 75 avif:-',
      },
      filetypes = {
        markdown = {
          template = '![image$CURSOR]($FILE_PATH)',
        },
        tex = {
          dir_path = './figs',
          extension = 'png',
          process_cmd = '',
          template = [[
    \begin{figure}[h]
      \centering
      \includegraphics[width=0.8\textwidth]{$FILE_PATH}
    \end{figure}
        ]], ---@type string | fun(context: table): string
        },
        typst = {
          dir_path = './figs',
          extension = 'png',
          process_cmd = 'magick convert - -density 300 png:-',
          template = [[
          #align(center)[#image("$FILE_PATH", height: 80%)]
          ]],
        },
      },
    },
    keys = {
      { '<leader>P', '<cmd>PasteImage<cr>', desc = 'Paste image from system clipboard' },
    },
  },
}
