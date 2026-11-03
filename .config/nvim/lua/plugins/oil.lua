vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local configured = false
local detail = false

function _G.get_oil_winbar()
	if configured then
		local dir = require("oil").get_current_dir()
		if dir then
			return vim.fn.fnamemodify(dir, ":~")
		end
	end
	return vim.api.nvim_buf_get_name(0)
end

local function setup_oil()
	if configured then
		return require("oil")
	end

	pcall(vim.api.nvim_del_user_command, "Oil")
	vim.pack.add({
		{ src = "https://github.com/stevearc/oil.nvim" },
	})

	local oil = require("oil")
	oil.setup({
		default_file_explorer = true,
		keymaps = {
			["<C-h>"] = false,
			["<C-l>"] = false,
			["<C-k>"] = false,
			["<C-j>"] = false,
			["<C-r>"] = "actions.refresh",
			["<leader>y"] = "actions.yank_entry",
			["g."] = false,
			["zh"] = "actions.toggle_hidden",
			["\\"] = { "actions.select", opts = { horizontal = true } },
			["|"] = { "actions.select", opts = { vertical = true } },
			["-"] = "actions.close",
			["<leader>e"] = "actions.close",
			["<BS>"] = "actions.parent",
			["gd"] = {
				desc = "Toggle file detail view",
				callback = function()
					detail = not detail
					if detail then
						require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
					else
						require("oil").set_columns({ "icon" })
					end
				end,
			},
		},
		win_options = {
			winbar = "%!v:lua.get_oil_winbar()",
		},
	})

	configured = true
	return oil
end

local function open_oil(path, count)
	setup_oil()
	local args = {}
	if path and path ~= "" then
		args[#args + 1] = path
	end
	local cmd = { cmd = "Oil", args = args }
	if count and count > 0 then
		cmd.count = count
	end
	vim.cmd(cmd)
end

vim.api.nvim_create_user_command("Oil", function(opts)
	open_oil(opts.args, opts.count)
end, {
	desc = "Open oil file browser on a directory",
	nargs = "*",
	complete = "dir",
	count = true,
})

vim.keymap.set("n", "-", function()
	open_oil(nil, 0)
end)

vim.api.nvim_create_autocmd({ "BufEnter", "VimEnter" }, {
	group = vim.api.nvim_create_augroup("LazyLoadOil", { clear = true }),
	callback = function(ev)
		if configured then
			return
		end

		local bufnr = ev.buf or vim.api.nvim_get_current_buf()
		if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
			return
		end

		local bufname = vim.api.nvim_buf_get_name(bufnr)
		if bufname == "" or vim.fn.isdirectory(bufname) == 0 then
			return
		end

		vim.schedule(function()
			if not vim.api.nvim_buf_is_valid(bufnr) then
				return
			end
			open_oil(bufname, 0)
		end)
	end,
})
