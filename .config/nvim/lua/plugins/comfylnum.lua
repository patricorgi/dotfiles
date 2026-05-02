local configured = false

local function load_comfylnum()
	if configured then
		return
	end

	configured = true
	vim.pack.add({
		{ src = "https://github.com/mluders/comfy-line-numbers.nvim" },
	})

	require("comfy-line-numbers").setup()
end

vim.api.nvim_create_autocmd("UIEnter", {
	group = vim.api.nvim_create_augroup("LoadComfyLineNumbers", { clear = true }),
	once = true,
	callback = function()
		vim.schedule(load_comfylnum)
	end,
})
