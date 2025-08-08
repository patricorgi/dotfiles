--
-- ██╗    ██╗███████╗███████╗████████╗███████╗██████╗ ███╗   ███╗
-- ██║    ██║██╔════╝╚══███╔╝╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
-- ██║ █╗ ██║█████╗    ███╔╝    ██║   █████╗  ██████╔╝██╔████╔██║
-- ██║███╗██║██╔══╝   ███╔╝     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║
-- ╚███╔███╔╝███████╗███████╗   ██║   ███████╗██║  ██║██║ ╚═╝ ██║
--  ╚══╝╚══╝ ╚══════╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
-- A GPU-accelerated cross-platform terminal emulator
-- https://wezfurlong.org/wezterm/

local k = require("utils/keys")
local wezterm = require("wezterm")
wezterm.on("gui-startup", function(cmd) -- set startup Window position
	local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():set_position(1000, 1000)
end)
local act = wezterm.action
local opacity = 1.0
local config = {
	-- ╭─────────────────────────────────────────────────────────╮
	-- │                         GENERAL                         │
	-- ╰─────────────────────────────────────────────────────────╯
	check_for_updates = false,
	-- ╭─────────────────────────────────────────────────────────╮
	-- │                       APPEARANCE                        │
	-- ╰─────────────────────────────────────────────────────────╯
	-- FONT
	font_size = 16,
	-- font = wezterm.font("JetBrainsMonoNL Nerd Font Mono", { weight = "Regular" }),
	-- font = wezterm.font("Hack Nerd Font", { weight = "Regular" }),
	font = wezterm.font_with_fallback({
		-- { family = "FiraCode Nerd Font Mono", weight = "Regular" },
		-- { family = "Hack Nerd Font", weight = "Regular" },
		-- { family = "MesloLGL Nerd Font Mono", weight = "Regular" },
		{ family = "JetBrains Mono", weight = "Regular" },
		{ family = "Sarasa Term SC Nerd", weight = "Regular" },
		{ family = "SF Pro", weight = "Regular" },
	}),
	line_height = 1.1,

	-- COLOR SCHEME
	color_scheme = "Catppuccin Mocha",
	set_environment_variables = {
		BAT_THEME = "Catppuccin-mocha",
	},

	-- WINDOW
	initial_cols = 127,
	initial_rows = 37,
	window_padding = {
		left = 15,
		right = 15,
		top = 15,
		bottom = 15,
	},
	adjust_window_size_when_changing_font_size = false,
	window_close_confirmation = "AlwaysPrompt",
	window_decorations = "RESIZE | MACOS_FORCE_ENABLE_SHADOW",
	window_background_opacity = opacity,
	macos_window_background_blur = 70,
	native_macos_fullscreen_mode = false,

	-- TABS
	enable_tab_bar = true,
	use_fancy_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,
	show_new_tab_button_in_tab_bar = false,
	colors = {
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
	},

	-- ╭─────────────────────────────────────────────────────────╮
	-- │                          KEYS                           │
	-- ╰─────────────────────────────────────────────────────────╯
	keys = {
		k.cmd_key("b", k.multiple_actions(":Neotree toggle")),
		k.cmd_key("p", k.multiple_actions(":Telescope find_files")),
		k.cmd_key("F", k.multiple_actions(":Telescope live_grep")),
		k.cmd_key("g", k.multiple_actions(":LazyGitCurrentFile")),
		k.cmd_key("G", k.multiple_actions(":Telescope git_submodules")),
		k.cmd_key("R", k.multiple_actions(":OverseerRestartLast")),
		k.cmd_key("r", k.multiple_actions(":OverseerRun")),
		k.cmd_ctrl_key("d", k.multiple_actions(":DiffviewFileHistory %")),
		k.cmd_key(
			"s",
			act.Multiple({
				act.SendKey({ key = "\x1b" }), -- escape
				k.multiple_actions(":w"),
			})
		),
		k.cmd_to_tmux_prefix("1", "1"),
		k.cmd_to_tmux_prefix("2", "2"),
		k.cmd_to_tmux_prefix("3", "3"),
		k.cmd_to_tmux_prefix("4", "4"),
		k.cmd_to_tmux_prefix("5", "5"),
		k.cmd_to_tmux_prefix("6", "6"),
		k.cmd_to_tmux_prefix("7", "7"),
		k.cmd_to_tmux_prefix("8", "8"),
		k.cmd_to_tmux_prefix("9", "9"),
		k.cmd_to_tmux_prefix("n", '"'), -- tmux horizontal split
		k.cmd_to_tmux_prefix("N", "%"), -- tmux vertical split
		k.cmd_to_tmux_prefix("d", "w"), -- tmux-sessionx
		k.cmd_to_tmux_prefix("t", "c"), -- new tmux window
		k.cmd_to_tmux_prefix("w", "x"), -- tmux close pane
		k.cmd_to_tmux_prefix("z", "z"), -- tmux zoom
		{
			key = "t",
			mods = "CMD|CTRL",
			action = wezterm.action.EmitEvent("toggle-opacity"),
		},
	},
}

return config
