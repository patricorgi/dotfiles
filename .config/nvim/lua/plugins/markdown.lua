local configured = false
local M = {}

function M.load()
	if configured then
		return require("render-markdown")
	end

	configured = true
	vim.pack.add({
		{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
	})

	return require("render-markdown")
end

return M
