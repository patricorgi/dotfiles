local configured = false

local function load_img_clip()
	if configured then
		return require("img-clip")
	end

	configured = true
	vim.pack.add({
		{ src = "https://github.com/HakonHarnes/img-clip.nvim" },
	})

	local img_clip = require("img-clip")
	img_clip.setup({
		default = {
			dir_path = "./attachments",
			use_absolute_path = false,
			copy_images = true,
			prompt_for_file_name = false,
			file_name = "%y%m%d-%H%M%S",
			extension = "avif",
			process_cmd = "magick convert - -quality 75 avif:-",
			formats = { "jpeg", "jpg", "png" },
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
        ]],
			},
			typst = {
				dir_path = "./figs",
				extension = "png",
				process_cmd = "magick convert - -density 300 png:-",
				formats = { "jpeg", "jpg", "png", "pdf", "svg" },
				template = [[
          #align(center)[#image("$FILE_PATH", height: 80%)]
          ]],
			},
		},
	})

	return img_clip
end

vim.api.nvim_create_user_command("PasteImage", function()
	load_img_clip().pasteImage()
end, { desc = "Lazy-load img-clip.nvim" })

vim.api.nvim_create_user_command("ImgClipDebug", function()
	load_img_clip()
	require("img-clip.debug").print_log()
end, { desc = "Lazy-load img-clip.nvim" })

vim.api.nvim_create_user_command("ImgClipConfig", function()
	load_img_clip()
	require("img-clip.config").print_config()
end, { desc = "Lazy-load img-clip.nvim" })

vim.keymap.set("n", "<leader>P", function()
	load_img_clip().pasteImage()
end, { desc = "Paste image from system clipboard" })
