return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown', 'Avante' },
    config = function()
      require 'custom.config.render-markdown'
    end,
  },
  { 'bullets-vim/bullets.vim', ft = { 'markdown' } },
  {
    'AndrewRadev/switch.vim',
    config = function()
      vim.keymap.set('n', '`', function()
        vim.cmd [[Switch]]
      end, { desc = 'Switch strings' })
    end,
  },
  {
    'HakonHarnes/img-clip.nvim',
    ft = { 'tex', 'markdown' },
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
      },
    },
    keys = {
      { '<leader>P', '<cmd>PasteImage<cr>', desc = 'Paste image from system clipboard' },
    },
  },
}
