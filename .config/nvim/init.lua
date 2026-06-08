vim.o.exrc = true

if vim.loader then
	vim.loader.enable()
end

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lsp")
require("config.treesitter_compat").setup()

require("plugins.catppuccin")
require("plugins.vpack")
require("plugins.vim-sleuth")
require("plugins.auto-session")
require("plugins.mini")
require("plugins.oil")
require("plugins.comfylnum")
require("plugins.heirline")
require("plugins.completion")
require("plugins.conform")
require("plugins.debugging")
require("plugins.treesitter")
require("plugins.snacks")
require("plugins.vim-tmux-navigator")
require("plugins.switch")
require("plugins.markdown")
require("plugins.typst")
require("plugins.latex")
require("plugins.img-clip")
require("plugins.todo-comments")
require("plugins.gitsigns")
require("plugins.opencode")
