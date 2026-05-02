vim.pack.add({
    { src = "https://github.com/rmagatti/auto-session" }
})
require("auto-session").setup({
	session_lens = {
		load_on_setup = false,
		picker = "snacks",
	},
})
