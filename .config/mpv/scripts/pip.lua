local mp = require("mp")

local saved
local properties = {
	"border",
	"title-bar",
	"ontop",
	"on-all-workspaces",
	"geometry",
	"autofit",
	"autofit-larger",
	"autofit-smaller",
	"window-maximized",
	"fullscreen",
}

local function toggle()
	if saved then
		local previous = saved
		saved = nil
		for _, name in ipairs(properties) do
			if name ~= "fullscreen" and name ~= "window-maximized" then
				mp.set_property_native(name, previous[name])
			end
		end
		mp.set_property_number("current-window-scale", previous.scale)
		mp.set_property_native("window-maximized", previous["window-maximized"])
		mp.set_property_native("fullscreen", previous.fullscreen)
		mp.osd_message("Picture-in-Picture off")
		return
	end

	local scale = mp.get_property_number("current-window-scale")
	if not scale then
		mp.osd_message("Open a video before enabling Picture-in-Picture")
		return
	end

	saved = { scale = scale }
	for _, name in ipairs(properties) do
		saved[name] = mp.get_property_native(name)
	end

	mp.set_property_native("fullscreen", false)
	mp.set_property_native("window-maximized", false)
	mp.set_property_native("border", false)
	mp.set_property_native("title-bar", false)
	mp.set_property_native("ontop", true)
	mp.set_property_native("on-all-workspaces", true)
	mp.set_property("geometry", "")
	mp.set_property("autofit-larger", "")
	mp.set_property("autofit-smaller", "")
	mp.set_property("autofit", "25%x25%")
	mp.osd_message("Picture-in-Picture on")
end

mp.add_key_binding(nil, "toggle", toggle)
