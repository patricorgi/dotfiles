---@diagnostic disable: param-type-mismatch
local palette = require("catppuccin.palettes").get_palette("mocha")
local icons = require("config.icons")
local api = vim.api
local b = vim.b
local bo = vim.bo
local fn = vim.fn
local fs = vim.fs

local M = {}

local dim_color = palette.surface1
local augroup = api.nvim_create_augroup("NativeStatusline", { clear = true })
local overseer_statuses = {
	{ key = "CANCELED", symbol = " 󰩹 ", group = "StatuslineOverseerCanceled" },
	{ key = "RUNNING", symbol = "  ", group = "StatuslineOverseerRunning" },
	{ key = "SUCCESS", symbol = "  ", group = "StatuslineOverseerSuccess" },
	{ key = "FAILURE", symbol = "  ", group = "StatuslineOverseerFailure" },
}

local state = {
	buffers = {},
	conform = nil,
	modified_groups = {},
	icon_cache = {},
	overseer = "",
	overseer_task_list = nil,
	overseer_util = nil,
	setup_done = false,
}

local mode_groups = {
	n = "StatuslineModeNormal",
	i = "StatuslineModeInsert",
	v = "StatuslineModeVisual",
	V = "StatuslineModeVisual",
	["\22"] = "StatuslineModeVisual",
	c = "StatuslineModeCommand",
	s = "StatuslineModeSelect",
	S = "StatuslineModeSelect",
	["\19"] = "StatuslineModeSelect",
	R = "StatuslineModeReplace",
	r = "StatuslineModeReplace",
	["!"] = "StatuslineModeCommand",
	t = "StatuslineModeTerminal",
}

local redraw_scheduled = false

local function redrawstatus()
	if redraw_scheduled then
		return
	end

	redraw_scheduled = true
	vim.schedule(function()
		redraw_scheduled = false
		pcall(vim.cmd, "redrawstatus")
	end)
end

local function get_buffer_state(bufnr)
	local buf_state = state.buffers[bufnr]
	if not buf_state then
		buf_state = {}
		state.buffers[bufnr] = buf_state
	end
	return buf_state
end

local function statusline_winid()
	local winid = tonumber(vim.g.statusline_winid)
	if winid and api.nvim_win_is_valid(winid) then
		return winid
	end
	return api.nvim_get_current_win()
end

local function statusline_escape(text)
	return tostring(text):gsub("%%", "%%%%")
end

local function with_hl(group, text)
	if text == "" then
		return ""
	end
	return ("%%#%s#%s%%*"):format(group, text)
end

local function hl_fg(group, fallback)
	local ok, hl = pcall(api.nvim_get_hl, 0, { name = group })
	if ok and hl and hl.fg then
		return string.format("#%06x", hl.fg)
	end
	return fallback
end

local function modified_group_name(source_hl)
	return "StatuslineFileModified" .. source_hl:gsub("[^%w]", "_")
end

local function ensure_modified_groups(source_hl)
	if not source_hl then
		return {
			icon = "StatuslineFileIconModifiedDefault",
			name = "StatuslineFileNameModifiedDefault",
			flags = "StatuslineFileFlagsModifiedDefault",
		}
	end

	local groups = state.modified_groups[source_hl]
	if groups then
		return groups
	end

	local prefix = modified_group_name(source_hl)
	local color = hl_fg(source_hl, palette.text)
	groups = {
		icon = source_hl,
		name = prefix .. "Name",
		flags = prefix .. "Flags",
	}
	state.modified_groups[source_hl] = groups
	api.nvim_set_hl(0, groups.name, { fg = color, italic = true })
	api.nvim_set_hl(0, groups.flags, { fg = color, bold = true })
	return groups
end

local function setup_highlights()
	api.nvim_set_hl(0, "StatuslineDim", { fg = dim_color })
	api.nvim_set_hl(0, "StatuslineGitDirty", { fg = palette.maroon })
	api.nvim_set_hl(0, "StatuslineSearch", { fg = palette.sky })
	api.nvim_set_hl(0, "StatuslineMacroIcon", { fg = palette.maroon })
	api.nvim_set_hl(0, "StatuslineMacroText", { fg = palette.maroon, bold = true })
	api.nvim_set_hl(0, "StatuslineReadonly", { fg = palette.text })
	api.nvim_set_hl(0, "StatuslineModeNormal", { fg = dim_color, bg = palette.base, bold = true })
	api.nvim_set_hl(0, "StatuslineModeInsert", { fg = palette.blue, bg = palette.base, bold = true })
	api.nvim_set_hl(0, "StatuslineModeVisual", { fg = palette.mauve, bg = palette.base, bold = true })
	api.nvim_set_hl(0, "StatuslineModeCommand", { fg = palette.red, bg = palette.base, bold = true })
	api.nvim_set_hl(0, "StatuslineModeSelect", { fg = palette.pink, bg = palette.base, bold = true })
	api.nvim_set_hl(0, "StatuslineModeReplace", { fg = palette.peach, bg = palette.base, bold = true })
	api.nvim_set_hl(0, "StatuslineModeTerminal", { fg = palette.blue, bg = palette.base, bold = true })
	api.nvim_set_hl(0, "StatuslineOverseerCanceled", { fg = hl_fg("OverseerCANCELED", palette.overlay1) })
	api.nvim_set_hl(0, "StatuslineOverseerRunning", { fg = hl_fg("OverseerRUNNING", palette.blue) })
	api.nvim_set_hl(0, "StatuslineOverseerSuccess", { fg = hl_fg("OverseerSUCCESS", palette.green) })
	api.nvim_set_hl(0, "StatuslineOverseerFailure", { fg = hl_fg("OverseerFAILURE", palette.red) })
	api.nvim_set_hl(0, "StatuslineFileIconModifiedDefault", { fg = palette.text })
	api.nvim_set_hl(0, "StatuslineFileNameModifiedDefault", { fg = palette.text, italic = true })
	api.nvim_set_hl(0, "StatuslineFileFlagsModifiedDefault", { fg = palette.text, bold = true })

	for source_hl, groups in pairs(state.modified_groups) do
		local color = hl_fg(source_hl, palette.text)
		api.nvim_set_hl(0, groups.name, { fg = color, italic = true })
		api.nvim_set_hl(0, groups.flags, { fg = color, bold = true })
	end
end

local function file_icon(filename, buftype)
	if filename == "" and buftype ~= "terminal" then
		return nil
	end

	local key = buftype == "terminal" and "terminal" or fn.fnamemodify(filename, ":e")
	local cached = state.icon_cache[key]
	if cached then
		return cached.icon, cached.hl
	end

	local icon
	local icon_hl
	if _G.MiniIcons and MiniIcons.get then
		local extension = fn.fnamemodify(filename, ":e")
		icon, icon_hl = MiniIcons.get("file", "file." .. extension)
	end
	if buftype == "terminal" then
		icon = ""
	end
	cached = { icon = icon, hl = icon_hl }
	state.icon_cache[key] = cached
	if not icon then
		return nil, nil
	end
	return icon, icon_hl
end

local function update_file_segment(bufnr)
	if not api.nvim_buf_is_valid(bufnr) then
		return
	end

	local buf_state = get_buffer_state(bufnr)
	local filename = api.nvim_buf_get_name(bufnr)
	local buf_opts = bo[bufnr]
	local parts = {}

	local icon, icon_hl = file_icon(filename, buf_opts.buftype)
	local modified_groups = buf_opts.modified and ensure_modified_groups(icon_hl) or nil

	if icon then
		local group = modified_groups and modified_groups.icon or "StatuslineDim"
		parts[#parts + 1] = with_hl(group, statusline_escape(icon .. " "))
	end

	local label = ""
	if filename == "" then
		label = buf_opts.filetype ~= "" and buf_opts.filetype or ""
	else
		label = fs.basename(filename) or filename
	end
	if label ~= "" then
		local group = modified_groups and modified_groups.name or "StatuslineDim"
		parts[#parts + 1] = with_hl(group, statusline_escape(label))
	end

	if filename ~= "" and modified_groups then
		parts[#parts + 1] = with_hl(modified_groups.flags, " [+]")
	end

	if buf_opts.buftype ~= "terminal" and (not buf_opts.modifiable or buf_opts.readonly) then
		parts[#parts + 1] = with_hl("StatuslineReadonly", " ")
	end

	buf_state.file = table.concat(parts)
	if buf_state.file ~= "" then
		buf_state.file = buf_state.file .. " "
	end
end

local function update_git_segment(bufnr)
	local buf_state = get_buffer_state(bufnr)
	local status_dict = b[bufnr].gitsigns_status_dict
	if not status_dict or not status_dict.head or status_dict.head == "" then
		buf_state.git = ""
		buf_state.git_signature = ""
		return
	end

	local signature = table.concat({
		status_dict.head,
		status_dict.added or 0,
		status_dict.removed or 0,
		status_dict.changed or 0,
	}, ":")
	if buf_state.git_signature == signature then
		return
	end

	buf_state.git_signature = signature
	local has_changes = (status_dict.added or 0) ~= 0
		or (status_dict.removed or 0) ~= 0
		or (status_dict.changed or 0) ~= 0
	local text = "󰘬 " .. status_dict.head
	if has_changes then
		text = text .. "*"
	end
	local group = has_changes and "StatuslineGitDirty" or "StatuslineDim"
	buf_state.git = with_hl(group, statusline_escape(text)) .. " "
end

local function update_diagnostics_segment(bufnr)
	if not api.nvim_buf_is_valid(bufnr) then
		return
	end

	if not package.loaded["vim.diagnostic"] then
		get_buffer_state(bufnr).diagnostics = ""
		return
	end

	local diagnostic = require("vim.diagnostic")
	local counts = diagnostic.count(bufnr)
	local errors = counts[diagnostic.severity.ERROR] or 0
	local warnings = counts[diagnostic.severity.WARN] or 0
	local info = counts[diagnostic.severity.INFO] or 0
	local hints = counts[diagnostic.severity.HINT] or 0
	local parts = {}

	if errors > 0 then
		parts[#parts + 1] = with_hl("DiagnosticError", statusline_escape(icons.diagnostics.Error .. errors .. " "))
	end
	if warnings > 0 then
		parts[#parts + 1] = with_hl("DiagnosticWarn", statusline_escape(icons.diagnostics.Warn .. warnings .. " "))
	end
	if info > 0 then
		parts[#parts + 1] = with_hl("DiagnosticInfo", statusline_escape(icons.diagnostics.Info .. info .. " "))
	end
	if hints > 0 then
		parts[#parts + 1] = with_hl("DiagnosticHint", statusline_escape(icons.diagnostics.Hint .. hints))
	end

	local buf_state = get_buffer_state(bufnr)
	buf_state.diagnostics = table.concat(parts)
	if buf_state.diagnostics ~= "" then
		buf_state.diagnostics = buf_state.diagnostics .. " "
	end
end

local function update_overseer_segment()
	if not package.loaded.overseer then
		state.overseer = ""
		return
	end

	if not state.overseer_task_list or not state.overseer_util then
		local ok_tasks, task_list = pcall(require, "overseer.task_list")
		local ok_util, util = pcall(require, "overseer.util")
		if not ok_tasks or not ok_util then
			state.overseer = ""
			return
		end
		state.overseer_task_list = task_list
		state.overseer_util = util
	end

	local tasks = state.overseer_task_list.list_tasks({ unique = true })
	local tasks_by_status = state.overseer_util.tbl_group_by(tasks, "status")
	local parts = {}

	for _, status in ipairs(overseer_statuses) do
		local status_tasks = tasks_by_status[status.key]
		if status_tasks then
			parts[#parts + 1] = with_hl(status.group, statusline_escape(status.symbol .. #status_tasks)) .. " "
		end
	end

	state.overseer = table.concat(parts)
end

local function search_segment()
	if vim.v.hlsearch ~= 1 then
		return ""
	end

	local ok, sinfo = pcall(fn.searchcount, { maxcount = 0, timeout = 50 })
	if not ok or type(sinfo) ~= "table" or (sinfo.total or 0) == 0 then
		return ""
	end

	if (sinfo.incomplete or 0) > 0 then
		return with_hl("StatuslineSearch", " [?/?]")
	end

	return with_hl("StatuslineSearch", (" [%d/%d]"):format(sinfo.current or 0, sinfo.total or 0))
end

local function macro_segment()
	local reg = fn.reg_recording()
	if reg == "" then
		return ""
	end
	return with_hl("StatuslineMacroIcon", "󰻃 ") .. with_hl("StatuslineMacroText", statusline_escape(reg))
end

local function showcmd_segment()
	if vim.o.cmdheight ~= 0 then
		return ""
	end
	return "%3.5(%S%)"
end

local function update_formatters_segment(bufnr)
	if not api.nvim_buf_is_valid(bufnr) then
		return
	end

	if not state.conform then
		local ok, conform = pcall(require, "conform")
		if ok then
			state.conform = conform
		end
	end

	local buf_state = get_buffer_state(bufnr)
	if not state.conform then
		buf_state.formatters = ""
		return
	end

	local ft_entry = state.conform.formatters_by_ft[bo[bufnr].filetype]
	local formatters = type(ft_entry) == "function" and ft_entry() or ft_entry
	if type(formatters) ~= "table" or vim.tbl_isempty(formatters) then
		buf_state.formatters = ""
		return
	end
	buf_state.formatters = with_hl("StatuslineDim", statusline_escape(table.concat(formatters, ","))) .. " "
end

local function update_filetype_segment(bufnr)
	if not api.nvim_buf_is_valid(bufnr) then
		return
	end

	local filetype = bo[bufnr].filetype
	local buf_state = get_buffer_state(bufnr)
	if filetype == "" then
		buf_state.filetype = ""
		return
	end

	local group = "StatuslineDim"
	if package.loaded["vim.lsp"] and next(require("vim.lsp").get_clients({ bufnr = bufnr })) then
		group = "Type"
	end
	buf_state.filetype = with_hl(group, statusline_escape(filetype)) .. " "
end

local function refresh_buffer(bufnr)
	update_file_segment(bufnr)
	update_git_segment(bufnr)
	update_diagnostics_segment(bufnr)
	update_formatters_segment(bufnr)
	update_filetype_segment(bufnr)
end

function M.render()
	local winid = statusline_winid()
	local bufnr = api.nvim_win_get_buf(winid)
	local buf_state = state.buffers[bufnr]
	if not buf_state then
		refresh_buffer(bufnr)
		buf_state = get_buffer_state(bufnr)
	end
	update_git_segment(bufnr)

	local parts = {
		with_hl(mode_groups[vim.fn.mode(1):sub(1, 1)] or "StatuslineModeNormal", "▌"),
		buf_state.file or "",
		buf_state.git or "",
		buf_state.diagnostics or "",
		state.overseer,
		search_segment(),
		"%=",
		showcmd_segment(),
		macro_segment(),
		"%=",
		buf_state.formatters or "",
		buf_state.filetype or "",
		"%4l,%-3c %P",
	}

	return table.concat(parts)
end

function M.setup()
	if state.setup_done then
		return
	end

	state.setup_done = true
	setup_highlights()
	update_overseer_segment()
	vim.o.cmdheight = 0
	vim.opt.showcmdloc = "statusline"
	vim.o.statusline = "%!v:lua.require'config.statusline'.render()"

	api.nvim_create_autocmd("ColorScheme", {
		group = augroup,
		callback = function()
			setup_highlights()
			redrawstatus()
		end,
	})

	api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
		group = augroup,
		callback = function(ev)
			refresh_buffer(ev.buf)
			redrawstatus()
		end,
	})

	api.nvim_create_autocmd({ "BufFilePost", "BufModifiedSet", "BufWritePost" }, {
		group = augroup,
		callback = function(ev)
			update_file_segment(ev.buf)
			update_git_segment(ev.buf)
			redrawstatus()
		end,
	})

	api.nvim_create_autocmd("DiagnosticChanged", {
		group = augroup,
		callback = function(ev)
			update_diagnostics_segment(ev.buf)
			redrawstatus()
		end,
	})

	api.nvim_create_autocmd("FileType", {
		group = augroup,
		callback = function(ev)
			update_file_segment(ev.buf)
			update_formatters_segment(ev.buf)
			update_filetype_segment(ev.buf)
			redrawstatus()
		end,
	})

	api.nvim_create_autocmd({ "LspAttach", "LspDetach" }, {
		group = augroup,
		callback = function(ev)
			update_filetype_segment(ev.buf)
			redrawstatus()
		end,
	})

	api.nvim_create_autocmd("OptionSet", {
		group = augroup,
		pattern = { "modifiable", "readonly" },
		callback = function()
			update_file_segment(api.nvim_get_current_buf())
			redrawstatus()
		end,
	})

	api.nvim_create_autocmd("User", {
		group = augroup,
		pattern = "OverseerListUpdate",
		callback = function()
			update_overseer_segment()
			redrawstatus()
		end,
	})

	api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
		group = augroup,
		callback = function(ev)
			state.buffers[ev.buf] = nil
		end,
	})

	api.nvim_create_autocmd({
		"ModeChanged",
		"RecordingEnter",
		"RecordingLeave",
		"WinEnter",
	}, {
		group = augroup,
		callback = redrawstatus,
	})
end

return M
