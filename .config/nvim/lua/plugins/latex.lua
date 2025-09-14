vim.g.vimtex_view_method = "skim"
vim.g.vimtex_view_skim_sync = 1
vim.g.vimtex_view_skim_activate = 1
vim.g.vimtex_compiler_progname = "nvr"
vim.g.vimtex_quickfix_ignore_filters = {
	"Underfull",
	"Overfull",
	"specifier changed to",
	"Token not allowed in a PDF string",
	"LaTeX Warning: Float too large for page",
	"contains only floats",
	"LaTeX Warning: Citation",
	'Missing "author" in',
	"LaTeX Font Warning:",
	'Package option "final" no longer has any effect with minted v3+',
}
vim.pack.add({
	{ src = "https://github.com/lervag/vimtex" },
})
