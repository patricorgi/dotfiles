local wezterm = require("wezterm")
local M = {}

local appearance = wezterm.gui.get_appearance()

M.is_dark = function()
	return appearance:find("Dark")
end

wezterm.on("toggle-opacity", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	if overrides.window_background_opacity == 1.0 then
		overrides.window_background_opacity = 0.9
		overrides.colors = {
			tab_bar = {
				background = "rgba(12%, 12%, 18%, 90%)",
				active_tab = {
					bg_color = "#cba6f7",
					fg_color = "rgba(12%, 12%, 18%, 0%)",
					intensity = "Bold",
				},
				inactive_tab = {
					fg_color = "#cba6f7",
					bg_color = "rgba(12%, 12%, 18%, 90%)",
					intensity = "Normal",
				},
				inactive_tab_hover = {
					fg_color = "#cba6f7",
					bg_color = "rgba(27%, 28%, 35%, 90%)",
					intensity = "Bold",
				},
				new_tab = {
					fg_color = "#808080",
					bg_color = "#1e1e2e",
				},
			},
		}
	else
		overrides.window_background_opacity = 1.0
		overrides.colors = {
			tab_bar = {
				background = "rgba(12%, 12%, 18%, 100%)",
				active_tab = {
					bg_color = "#cba6f7",
					fg_color = "rgba(12%, 12%, 18%, 100%)",
					intensity = "Bold",
				},
				inactive_tab = {
					fg_color = "#cba6f7",
					bg_color = "rgba(12%, 12%, 18%, 100%)",
					intensity = "Normal",
				},
				inactive_tab_hover = {
					fg_color = "#cba6f7",
					bg_color = "rgba(27%, 28%, 35%, 100%)",
					intensity = "Bold",
				},
				new_tab = {
					fg_color = "#808080",
					bg_color = "#1e1e2e",
				},
			},
		}
	end
	window:set_config_overrides(overrides)
end)

return M
