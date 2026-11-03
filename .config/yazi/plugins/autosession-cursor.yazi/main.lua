local function is_ignored(cwd)
	local dir = Url(cwd)
	while dir do
		if fs.cha(dir:join(".yaziignore")) ~= nil then
			return true
		end
		dir = dir.parent
	end
	return false
end

local get_current_session = ya.sync(function()
	local tabs = cx.tabs
	local session = {
		active_idx = tabs.idx,
		tabs = {},
	}

	for idx, tab in ipairs(tabs) do
		local cwd = tostring(tab.current.cwd):gsub("\\", "/")
		session.tabs[idx] = {
			cwd = cwd,
			hovered = tab.current.hovered and tostring(tab.current.hovered.url) or nil,
			sort = {
				by = tab.pref.sort_by,
				sensitive = tab.pref.sort_sensitive,
				reverse = tab.pref.sort_reverse,
				dir_first = tab.pref.sort_dir_first,
				translit = tab.pref.sort_translit,
			},
			linemode = tab.pref.linemode,
			show_hidden = tab.pref.show_hidden and "show" or "hide",
		}
	end

	return session
end)

local function session_event(cwd)
	local first, second = 0, 0
	local path = tostring(cwd)

	for index = 1, #path do
		local byte = string.byte(path, index)
		first = (first * 31 + byte) % 2147483647
		second = (second * 131 + byte) % 2147483629
	end

	return string.format("@autosession-cursor-%08x-%08x", first, second)
end

local function filter_session(session)
	local filtered = { active_idx = 1, tabs = {} }
	for idx, tab in ipairs(session.tabs) do
		if not is_ignored(tab.cwd) then
			filtered.tabs[#filtered.tabs + 1] = tab
			if idx <= session.active_idx then
				filtered.active_idx = #filtered.tabs
			end
		end
	end
	return filtered
end

local save_and_quit = ya.sync(function(state, session)
	if #session.tabs > 0 then
		ps.pub_to(0, state.event, session)
	end
	ya.emit("quit", {})
end)

local restore_session = ya.sync(function(state)
	for idx, tab in ipairs(state.session.tabs) do
		if idx == 1 then
			ya.emit("cd", { tab.cwd })
		else
			ya.emit("tab_create", { tab.cwd })
		end
		ya.emit("sort", tab.sort)
		ya.emit("linemode", { tab.linemode })
		ya.emit("hidden", { tab.show_hidden })
		if tab.hovered then
			ya.emit("reveal", { tab.hovered })
		end
	end

	ya.emit("tab_switch", { state.session.active_idx - 1 })
	state.restored = true
end)

return {
	setup = function(state)
		state.restored = false
		local cwd = os.getenv("PWD") or "."
		state.event = session_event(cwd)

		ps.sub_remote(state.event, function(session)
			if not state.restored then
				state.session = session
				restore_session()
			end
		end)
	end,

	entry = function(_, job)
		if job.args[1] == "save-and-quit" then
			save_and_quit(filter_session(get_current_session()))
		end
	end,
}
