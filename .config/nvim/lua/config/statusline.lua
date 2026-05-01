---@diagnostic disable: param-type-mismatch
local palette = require("catppuccin.palettes").get_palette("mocha")
local icons = require("config.icons")

local M = {}

local dim_color = palette.surface1
local augroup = vim.api.nvim_create_augroup("NativeStatusline", { clear = true })
local state = {
	highlights_ready = false,
	last_file_color = nil,
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

local function redrawstatus()
	pcall(vim.cmd, "redrawstatus")
end

local function statusline_winid()
	local winid = tonumber(vim.g.statusline_winid)
	if winid and vim.api.nvim_win_is_valid(winid) then
		return winid
	end
	return vim.api.nvim_get_current_win()
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
	local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group })
	if ok and hl and hl.fg then
		return string.format("#%06x", hl.fg)
	end
	return fallback
end

local function update_file_highlights(color)
	if state.last_file_color == color then
		return
	end
	state.last_file_color = color
	vim.api.nvim_set_hl(0, "StatuslineFileIconModified", { fg = color })
	vim.api.nvim_set_hl(0, "StatuslineFileNameModified", { fg = color, italic = true })
	vim.api.nvim_set_hl(0, "StatuslineFileFlagsModified", { fg = color, bold = true })
end

local function setup_highlights()
	vim.api.nvim_set_hl(0, "StatuslineDim", { fg = dim_color })
	vim.api.nvim_set_hl(0, "StatuslineGitDirty", { fg = palette.maroon })
	vim.api.nvim_set_hl(0, "StatuslineSearch", { fg = palette.sky })
	vim.api.nvim_set_hl(0, "StatuslineMacroIcon", { fg = palette.maroon })
	vim.api.nvim_set_hl(0, "StatuslineMacroText", { fg = palette.maroon, bold = true })
	vim.api.nvim_set_hl(0, "StatuslineReadonly", { fg = palette.text })
	vim.api.nvim_set_hl(0, "StatuslineModeNormal", { fg = dim_color, bg = palette.base, bold = true })
	vim.api.nvim_set_hl(0, "StatuslineModeInsert", { fg = palette.blue, bg = palette.base, bold = true })
	vim.api.nvim_set_hl(0, "StatuslineModeVisual", { fg = palette.mauve, bg = palette.base, bold = true })
	vim.api.nvim_set_hl(0, "StatuslineModeCommand", { fg = palette.red, bg = palette.base, bold = true })
	vim.api.nvim_set_hl(0, "StatuslineModeSelect", { fg = palette.pink, bg = palette.base, bold = true })
	vim.api.nvim_set_hl(0, "StatuslineModeReplace", { fg = palette.peach, bg = palette.base, bold = true })
	vim.api.nvim_set_hl(0, "StatuslineModeTerminal", { fg = palette.blue, bg = palette.base, bold = true })
	vim.api.nvim_set_hl(0, "StatuslineOverseerCanceled", { fg = hl_fg("OverseerCANCELED", palette.overlay1) })
	vim.api.nvim_set_hl(0, "StatuslineOverseerRunning", { fg = hl_fg("OverseerRUNNING", palette.blue) })
	vim.api.nvim_set_hl(0, "StatuslineOverseerSuccess", { fg = hl_fg("OverseerSUCCESS", palette.green) })
	vim.api.nvim_set_hl(0, "StatuslineOverseerFailure", { fg = hl_fg("OverseerFAILURE", palette.red) })
	update_file_highlights(palette.text)
	state.highlights_ready = true
end

local function ensure_highlights()
	if not state.highlights_ready then
		setup_highlights()
	end
end

local function file_icon(filename, buftype)
	if vim.fn.fnamemodify(filename, ":.") == "" then
		return nil, nil
	end

	local icon = nil
	local icon_hl = nil
	local extension = vim.fn.fnamemodify(filename, ":e")
	if _G.MiniIcons and MiniIcons.get then
		icon, icon_hl = MiniIcons.get("file", "file." .. extension)
	end
	if buftype == "terminal" then
		icon = ""
	end
	if not icon then
		return nil, nil
	end
	return icon, hl_fg(icon_hl, dim_color)
end

local function file_segment(bufnr)
	local filename = vim.api.nvim_buf_get_name(bufnr)
	local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
	local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
	local modified = vim.api.nvim_get_option_value("modified", { buf = bufnr })
	local modifiable = vim.api.nvim_get_option_value("modifiable", { buf = bufnr })
	local readonly = vim.api.nvim_get_option_value("readonly", { buf = bufnr })
	local parts = {}

	local icon, icon_color = file_icon(filename, buftype)
	if modified then
		update_file_highlights(icon_color or palette.text)
	end

	if icon then
		local group = modified and "StatuslineFileIconModified" or "StatuslineDim"
		parts[#parts + 1] = with_hl(group, statusline_escape(icon .. " "))
	end

	local label = ""
	if filename == "" then
		label = filetype ~= "" and filetype or ""
	else
		label = vim.fn.fnamemodify(filename, ":t")
	end
	if label ~= "" then
		local group = modified and "StatuslineFileNameModified" or "StatuslineDim"
		parts[#parts + 1] = with_hl(group, statusline_escape(label))
	end

	if vim.fn.fnamemodify(filename, ":.") ~= "" and modified then
		parts[#parts + 1] = with_hl("StatuslineFileFlagsModified", " [+]")
	end

	if buftype ~= "terminal" and (not modifiable or readonly) then
		parts[#parts + 1] = with_hl("StatuslineReadonly", " ")
	end

	local segment = table.concat(parts)
	if segment == "" then
		return ""
	end
	return segment .. " "
end

local function git_segment(bufnr)
	local status_dict = vim.b[bufnr].gitsigns_status_dict
	if not status_dict or not status_dict.head or status_dict.head == "" then
		return ""
	end

	local has_changes = (status_dict.added or 0) ~= 0
		or (status_dict.removed or 0) ~= 0
		or (status_dict.changed or 0) ~= 0
	local text = "󰘬 " .. status_dict.head
	if has_changes then
		text = text .. "*"
	end
	local group = has_changes and "StatuslineGitDirty" or "StatuslineDim"
	return with_hl(group, statusline_escape(text)) .. " "
end

local function diagnostics_segment(bufnr)
	local errors = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })
	local warnings = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.WARN })
	local info = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.INFO })
	local hints = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.HINT })
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

	local segment = table.concat(parts)
	if segment == "" then
		return ""
	end
	return segment .. " "
end

local function overseer_segment()
	if not package.loaded.overseer then
		return ""
	end

	local ok_tasks, task_list = pcall(require, "overseer.task_list")
	local ok_util, util = pcall(require, "overseer.util")
	if not ok_tasks or not ok_util then
		return ""
	end

	local tasks = task_list.list_tasks({ unique = true })
	local tasks_by_status = util.tbl_group_by(tasks, "status")
	local statuses = {
		{ key = "CANCELED", symbol = " 󰩹 ", group = "StatuslineOverseerCanceled" },
		{ key = "RUNNING", symbol = "  ", group = "StatuslineOverseerRunning" },
		{ key = "SUCCESS", symbol = "  ", group = "StatuslineOverseerSuccess" },
		{ key = "FAILURE", symbol = "  ", group = "StatuslineOverseerFailure" },
	}
	local parts = {}

	for _, status in ipairs(statuses) do
		local status_tasks = tasks_by_status[status.key]
		if status_tasks then
			parts[#parts + 1] = with_hl(status.group, statusline_escape(status.symbol .. #status_tasks)) .. " "
		end
	end

	return table.concat(parts)
end

local function search_segment()
	if vim.v.hlsearch ~= 1 then
		return ""
	end

	local ok, sinfo = pcall(vim.fn.searchcount, { maxcount = 0 })
	if not ok or type(sinfo) ~= "table" or (sinfo.total or 0) == 0 then
		return ""
	end

	if (sinfo.incomplete or 0) > 0 then
		return with_hl("StatuslineSearch", " [?/?]")
	end

	return with_hl("StatuslineSearch", (" [%d/%d]"):format(sinfo.current or 0, sinfo.total or 0))
end

local function macro_segment()
	local reg = vim.fn.reg_recording()
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

local function formatters_segment(bufnr)
	local ok, conform = pcall(require, "conform")
	if not ok then
		return ""
	end

	local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
	local ft_entry = conform.formatters_by_ft[filetype]
	local formatters = type(ft_entry) == "function" and ft_entry() or ft_entry
	if type(formatters) ~= "table" or vim.tbl_isempty(formatters) then
		return ""
	end
	return with_hl("StatuslineDim", statusline_escape(table.concat(formatters, ","))) .. " "
end

local function filetype_segment(bufnr)
	local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
	if filetype == "" then
		return ""
	end

	local group = #vim.lsp.get_clients({ bufnr = bufnr }) > 0 and "Type" or "StatuslineDim"
	return with_hl(group, statusline_escape(filetype)) .. " "
end

function M.render()
	ensure_highlights()

	local winid = statusline_winid()
	local bufnr = vim.api.nvim_win_get_buf(winid)
	local parts = {
		with_hl(mode_groups[vim.fn.mode(1):sub(1, 1)] or "StatuslineModeNormal", "▌"),
		file_segment(bufnr),
		git_segment(bufnr),
		diagnostics_segment(bufnr),
		overseer_segment(),
		search_segment(),
		"%=",
		showcmd_segment(),
		macro_segment(),
		"%=",
		formatters_segment(bufnr),
		filetype_segment(bufnr),
		"%4l,%-3c %P",
	}

	return table.concat(parts)
end

function M.setup()
	setup_highlights()
	vim.o.cmdheight = 0
	vim.opt.showcmdloc = "statusline"
	vim.o.statusline = "%!v:lua.require'config.statusline'.render()"

	vim.api.nvim_create_autocmd("ColorScheme", {
		group = augroup,
		callback = setup_highlights,
	})

	vim.api.nvim_create_autocmd({
		"BufEnter",
		"DiagnosticChanged",
		"LspAttach",
		"LspDetach",
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
