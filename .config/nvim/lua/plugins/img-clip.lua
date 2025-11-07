vim.pack.add({
    { src = "https://github.com/HakonHarnes/img-clip.nvim" },
})
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("SetupImgClip", { clear = true }),
    pattern = { "typst", "tex", "markdown" },
    once = true,
    callback = function()
        require("img-clip").setup({
            default = {
                dir_path = "./attachments",
                use_absolute_path = false,
                copy_images = true,
                prompt_for_file_name = false,
                file_name = "%y%m%d-%H%M%S",
                extension = "avif",
                process_cmd = "magick convert - -quality 75 avif:-",
            },
            filetypes = {
                markdown = {
                    template = "![image$CURSOR]($FILE_PATH)",
                },
                tex = {
                    dir_path = "./figs",
                    extension = "png",
                    process_cmd = "",
                    template = [[
    \begin{figure}[h]
      \centering
      \includegraphics[width=0.8\textwidth]{$FILE_PATH}
    \end{figure}
        ]], ---@type string | fun(context: table): string
                },
                typst = {
                    dir_path = "./figs",
                    extension = "png",
                    process_cmd = "magick convert - -density 300 png:-",
                    formats = { "jpeg", "jpg", "png", "pdf", "svg" }, ---@type table
                    template = [[
          #align(center)[#image("$FILE_PATH", height: 80%)]
          ]],
                },
            },
        })
        vim.keymap.set("n", "<leader>P", "<cmd>PasteImage<cr>", { desc = "Paste image from system clipboard" })
    end,
})
