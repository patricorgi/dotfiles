local configured = false

local function load_conform()
	if configured then
		return require("conform")
	end

	configured = true
	vim.pack.add({
		{ src = "https://github.com/stevearc/conform.nvim" },
	})

	local conform = require("conform")
	local cargo_bin = vim.fs.joinpath(vim.env.HOME, ".cargo", "bin")
	local tex_fmt = vim.fs.joinpath(cargo_bin, "tex-fmt")

	conform.setup({
		formatters_by_ft = {
			c = { "lcg_clang_format", "clang_format", stop_after_first = true },
			cpp = { "lcg_clang_format", "clang_format", stop_after_first = true },
			cuda = { "lcg_clang_format", "clang_format", stop_after_first = true },
			json = { "prettierd", "prettier", stop_after_first = true },
			jsonc = { "prettierd", "prettier", stop_after_first = true },
			lua = { "stylua" },
			python = { "ruff_format", "yapf", stop_after_first = true },
			sh = { "shfmt" },
			tex = { "tex_fmt" },
			latex = { "tex_fmt" },
			typst = { "typstyle" },
		},
		formatters = {
			lcg_clang_format = {
				command = "lcg-clang-format-8.0.0",
				args = { "--assume-filename", "$FILENAME" },
				stdin = true,
			},
			tex_fmt = {
				command = tex_fmt,
				args = { "--stdin", "--quiet" },
				stdin = true,
			},
		},
	})

	return conform
end

local function format(opts)
	load_conform().format(vim.tbl_extend("force", {
		async = true,
		lsp_format = "fallback",
	}, opts or {}))
end

vim.keymap.set({ "n", "v" }, "<leader>lf", function()
	format()
end, { desc = "Format buffer" })
