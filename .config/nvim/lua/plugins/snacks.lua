local M = {}

local configured = false

local function setup()
	if configured then
		return require("snacks")
	end

	configured = true
	vim.pack.add({
		{ src = "https://github.com/folke/snacks.nvim" },
	})

	local snacks = require("snacks")
	snacks.setup({
		notifier = {},
		input = {},
		picker = {
			ui_select = true,
			matcher = { frecency = true, cwd_bonus = true, history_bonus = true },
			formatters = { icon_width = 3 },
			win = {
				input = {
					keys = {
						["<C-t>"] = { "edit_tab", mode = { "n", "i" } },
					},
				},
			},
		},
		dashboard = {
			enabled = true,
			preset = {
				keys = {
					{ icon = "󰈞 ", key = "f", desc = "Find files", action = ":lua Snacks.picker.smart()" },
					{ icon = " ", key = "o", desc = "Find history", action = "lua Snacks.picker.recent()" },
					{ icon = " ", key = "e", desc = "New file", action = ":enew" },
					{ icon = " ", key = "o", desc = "Recent files", action = ":lua Snacks.picker.recent()" },
					{ icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
					{
						icon = "󰔛 ",
						key = "P",
						desc = "Lazy Profile",
						action = ":Lazy profile",
						enabled = package.loaded.lazy ~= nil,
					},
					{ icon = " ", key = "M", desc = "Mason", action = ":Mason", enabled = package.loaded.lazy ~= nil },
					{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
				},
				header = [[
░  ░░░░░░░░  ░░░░  ░░░      ░░░  ░░░░░░░
▒  ▒▒▒▒▒▒▒▒  ▒▒▒▒  ▒▒  ▒▒▒▒  ▒▒  ▒▒▒▒▒▒▒
▓  ▓▓▓▓▓▓▓▓        ▓▓  ▓▓▓▓▓▓▓▓       ▓▓
█  ████████  ████  ██  ████  ██  ████  █
█        ██  ████  ███      ███       ██
]],
			},
			sections = {
				{ section = "header" },
				{ icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
			},
		},
		image = {
			enabled = true,
			doc = { enabled = true, inline = false, float = true, max_width = 50, max_height = 50 },
		},
		indent = {
			enabled = false,
			indent = { enabled = false },
			animate = { duration = { step = 10, duration = 100 } },
			scope = { enabled = true, char = "┊", underline = false, only_current = true, priority = 1000 },
		},
		styles = {
			snacks_image = {
				border = "rounded",
				backdrop = false,
			},
		},
	})

	return snacks
end

M.load = setup

local function map(key, func, desc)
	vim.keymap.set("n", key, func, { desc = desc })
end

local function with_snacks(callback)
	return function(...)
		return callback(setup(), ...)
	end
end

local function markdown_lsp_symbol_format(item, picker)
	local format = require("snacks.picker.format")
	local ret = {}
	if item.tree and not picker.opts.workspace then
		vim.list_extend(ret, format.tree(item, picker))
	end

	local kind = item.lsp_kind or item.kind or "Unknown"
	local known_kind = picker.opts.icons.kinds[kind] ~= nil
	local icon = known_kind and picker.opts.icons.kinds[kind] or picker.opts.icons.kinds.Unknown
	local kind_hl = "SnacksPickerIcon" .. (known_kind and kind or "Unknown")

	if kind == "String" and item.buf and vim.bo[item.buf].filetype == "markdown" and item.pos then
		local line = vim.api.nvim_buf_get_lines(item.buf, item.pos[1] - 1, item.pos[1], false)[1] or ""
		local hashes = line:match("^%s*(#+)%s")
		local heading_icons = vim.b[item.buf].render_markdown_heading_icons
		if hashes and heading_icons then
			icon = heading_icons[math.min(#hashes, #heading_icons)] or icon
		end
	end

	ret[#ret + 1] = { icon, kind_hl }
	ret[#ret + 1] = { " " }
	local name = vim.trim(item.name:gsub("\r?\n", " "))
	name = name == "" and item.detail or name
	Snacks.picker.highlight.format(item, name, ret)
	return ret
end

map("<leader>ff", with_snacks(function(snacks)
	snacks.picker.smart()
end), "Smart find file")

map("<leader>fo", with_snacks(function(snacks)
	snacks.picker.recent()
end), "Find recent file")

map("<leader>fw", with_snacks(function(snacks)
	snacks.picker.grep()
end), "Find content")

map("<leader>fh", with_snacks(function(snacks)
	snacks.picker.help({ layout = "dropdown" })
end), "Find in help")

map("<leader>fl", with_snacks(function(snacks)
	snacks.picker.picker_layouts()
end), "Find picker layout")

map("<leader>fk", with_snacks(function(snacks)
	snacks.picker.keymaps({ layout = "dropdown" })
end), "Find keymap")

map("<leader><leader>", with_snacks(function(snacks)
	snacks.picker.buffers({ sort_lastused = true })
end), "Find buffers")

map("<leader>fm", with_snacks(function(snacks)
	snacks.picker.marks()
end), "Find mark")

map("<leader>fn", with_snacks(function(snacks)
	snacks.picker.notifications({ layout = "dropdown" })
end), "Find notification")

map("grr", with_snacks(function(snacks)
	snacks.picker.lsp_references({ include_declaration = false, include_current = true })
end), "Find lsp references")

map("<leader>fS", with_snacks(function(snacks)
	snacks.picker.lsp_workspace_symbols()
end), "Find workspace symbol")

map("<leader>fs", with_snacks(function(snacks)
	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients({ bufnr = bufnr })

	local function has_lsp_symbols()
		for _, client in ipairs(clients) do
			if client.server_capabilities.documentSymbolProvider then
				return true
			end
		end
		return false
	end

	if has_lsp_symbols() then
		snacks.picker.lsp_symbols({
			layout = "dropdown",
			tree = true,
			format = vim.bo[bufnr].filetype == "markdown" and markdown_lsp_symbol_format or "lsp_symbol",
		})
	else
		snacks.picker.treesitter()
	end
end), "Find symbol in current buffer")

map("<leader>fi", with_snacks(function(snacks)
	snacks.picker.icons()
end), "Find icon")

map("<leader>fI", with_snacks(function(snacks)
	snacks.picker.lsp_incoming_calls()
end), "Find incoming calls")

map("<leader>fO", with_snacks(function(snacks)
	snacks.picker.lsp_outgoing_calls({ tree = true })
end), "Find outgoing calls")

map("<leader>fT", with_snacks(function(snacks)
	snacks.picker.lsp_type_definitions()
end), "Find type definitions")

map("<leader>fb", with_snacks(function(snacks)
	snacks.picker.lines()
end), "Find lines in current buffer")

map("<leader>fd", with_snacks(function(snacks)
	snacks.picker.diagnostics_buffer()
end), "Find diagnostic in current buffer")

map("<leader>fH", with_snacks(function(snacks)
	snacks.picker.highlights()
end), "Find highlight")

map("<leader>fc", with_snacks(function(snacks)
	snacks.picker.files({ cwd = vim.fn.stdpath("config") })
end), "Find nvim config file")

map("<leader>f/", with_snacks(function(snacks)
	snacks.picker.search_history()
end), "Find search history")

map("<leader>fj", with_snacks(function(snacks)
	snacks.picker.jumps()
end), "Find jump")

map("<leader>fN", with_snacks(function(snacks)
	snacks.picker.todo_comments({ keywords = { "NOTE" }, layout = "select", buffers = true })
end), "Find todo")

map("<leader>ft", with_snacks(function(snacks)
	if vim.bo.filetype == "markdown" then
		snacks.picker.grep_buffers({
			finder = "grep",
			format = "file",
			prompt = " ",
			search = "^\\s*- \\[ \\]",
			regex = true,
			live = false,
			args = { "--no-ignore" },
			on_show = function()
				vim.cmd.stopinsert()
			end,
			buffers = false,
			supports_live = false,
			layout = "ivy",
		})
	else
		snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME", "HACK" }, layout = "select", buffers = true })
	end
end), "Find todo")

map("<leader>fF", with_snacks(function(snacks)
	snacks.picker.lines({ search = "FCN=" })
end))

map("<leader>bc", with_snacks(function(snacks)
	snacks.bufdelete.delete()
end), "Delete buffers")

map("<leader>bC", with_snacks(function(snacks)
	snacks.bufdelete.other()
end), "Delete other buffers")

map("<leader>gg", with_snacks(function(snacks)
	snacks.lazygit({ cwd = snacks.git.get_root() })
end), "Open lazygit")

map("<leader>n", with_snacks(function(snacks)
	snacks.notifier.show_history()
end), "Notification history")

map("<leader>N", with_snacks(function(snacks)
	snacks.notifier.hide()
end), "Notification history")

map("<leader>gb", with_snacks(function(snacks)
	snacks.git.blame_line()
end), "Git blame line")

map("<leader>K", with_snacks(function(snacks)
	snacks.image.hover()
end), "Display image in hover")

local function get_tabs()
	local tabs = {}
	local tabpages = vim.api.nvim_list_tabpages()
	for i, tabpage in ipairs(tabpages) do
		local wins = vim.api.nvim_tabpage_list_wins(tabpage)
		local cur_win = vim.api.nvim_tabpage_get_win(tabpage)
		local buf = vim.api.nvim_win_get_buf(cur_win)
		local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
		if name == "" then
			name = "[No Name]"
		end

		local preview_lines = {}
		table.insert(preview_lines, ("Tab %d: %d window%s"):format(i, #wins, #wins == 1 and "" or "s"))
		table.insert(preview_lines, ("%-6s %-8s %s"):format("WinID", "Buf#", "File"))
		table.insert(preview_lines, string.rep("-", 40))
		for _, win in ipairs(wins) do
			local win_buf = vim.api.nvim_win_get_buf(win)
			local bufname = vim.api.nvim_buf_get_name(win_buf)
			if bufname == "" then
				bufname = "[No Name]"
			end
			bufname = vim.fn.fnamemodify(bufname, ":~:.")
			local win_marker = (win == cur_win) and "->" or "  "
			table.insert(preview_lines, ("%s %-6d %-8d %s"):format(win_marker, win, win_buf, bufname))
		end
		if #wins == 0 then
			table.insert(preview_lines, "No windows in tab")
		end

		table.insert(tabs, {
			idx = i,
			text = ("Tab %d: %s"):format(i, name),
			tabnr = i,
			tabpage = tabpage,
			preview = {
				text = table.concat(preview_lines, "\n"),
				ft = "text",
			},
		})
	end
	return tabs
end

local function tabs_picker()
	local snacks = setup()
	local items = get_tabs()
	snacks.picker({
		title = "Tabs",
		items = items,
		format = "text",
		confirm = function(picker, item)
			picker:close()
			vim.cmd(("tabnext %d"):format(item.tabnr))
		end,
		preview = "preview",
		actions = {
			close_tab = function(picker, item)
				picker:close()
				vim.cmd(("tabclose %d"):format(item.tabnr))
			end,
		},
		win = {
			input = {
				keys = {
					["d"] = "close_tab",
				},
			},
		},
	})
end

map("<leader>fT", tabs_picker, "Display image in hover")

if vim.fn.argc() == 0 then
	vim.api.nvim_create_autocmd("VimEnter", {
		group = vim.api.nvim_create_augroup("LoadSnacksDashboard", { clear = true }),
		once = true,
		callback = function()
			local buf = vim.api.nvim_get_current_buf()
			local lines = vim.api.nvim_buf_get_lines(buf, 0, 1, false)
			if vim.api.nvim_buf_get_name(buf) == "" and vim.bo[buf].buftype == "" and lines[1] == "" then
				setup()
			end
		end,
	})
end

return M
