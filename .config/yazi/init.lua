local function setup_plugin(name, opts)
	local ok, plugin = pcall(require, name)
	if ok then
		pcall(function()
			plugin:setup(opts)
		end)
	end
end

setup_plugin("sshfs", {
	custom_hosts_file = os.getenv("HOME") .. "/.config/yazi/sshfs.list",
	mount_dir = os.getenv("HOME") .. "/SSHFS",
	sshfs_options = {
		"reconnect",
		"ConnectTimeout=5",
		"compression=no",
		"ServerAliveInterval=15",
		"ServerAliveCountMax=3",
		"cache=yes",
		"cache_timeout=5",
		"entry_timeout=5",
		"attr_timeout=5",
		"negative_timeout=1",
	},
})
setup_plugin("zoxide-track")
setup_plugin("autosession-cursor")

function Linemode:size_and_mtime()
	local year = os.date("%Y")
	local time = (self._file.cha.mtime or 0) // 1

	if time > 0 and os.date("%Y", time) == year then
		time = os.date("%b %d %H:%M", time)
	else
		time = time and os.date("%b %d  %Y", time) or ""
	end

	local size = self._file:size()
	return ui.Line(string.format(" %s %s ", size and ya.readable_size(size) or "-", time))
end

local function row_width(file)
	return Entity:new(file):redraw():width() + Linemode:new(file):redraw():width()
end

local tab_build = Tab.build
function Tab:build()
	local chunks = self._chunks
	-- Leave hidden/maximized layouts from toggle-pane alone.
	if chunks[1].w > 0 and chunks[2].w > 0 and chunks[3].w > 0 then
		local parent = self._tab.parent
		local hovered = parent and parent.hovered
		local parent_width = hovered and row_width(hovered) + 1 or 0
		local current_width = 0
		for _, file in ipairs(self._tab.current.window) do
			current_width = math.max(current_width, row_width(file) + 2)
		end

		local width = self._area.w
		local preview_min = math.min(24, math.floor(width / 4))
		parent_width = parent and math.min(math.max(12, parent_width), math.floor(width * 0.3)) or 0
		current_width = math.min(math.max(24, current_width), width - parent_width - preview_min)
		self._chunks = ui.Layout()
			:direction(ui.Layout.HORIZONTAL)
			:constraints({
				ui.Constraint.Length(parent_width),
				ui.Constraint.Length(current_width),
				ui.Constraint.Fill(1),
			})
			:split(self._area)
	end
	return tab_build(self)
end

Status:children_add(function(self)
	local h = self._current.hovered
	if h and h.link_to then
		return " -> " .. tostring(h.link_to)
	else
		return ""
	end
end, 3300, Status.LEFT)
