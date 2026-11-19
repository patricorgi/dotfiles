local mp = require("mp")
local msg = require("mp.msg")

local background_requested = false
local hide_if_windowless = [[
ObjC.import("AppKit");
ObjC.import("CoreGraphics");
function run(argv) {
    const pid = Number(argv[0]);
    const app = $.NSRunningApplication.runningApplicationWithProcessIdentifier(pid);
    for (let attempt = 0; attempt < 20; attempt++) {
        if (app.isNil() || app.terminated || !app.active) return;
        const windows = ObjC.deepUnwrap(ObjC.castRefToObject($.CGWindowListCopyWindowInfo(
            $.kCGWindowListOptionOnScreenOnly | $.kCGWindowListExcludeDesktopElements,
            $.kCGNullWindowID
        )));
        if (!windows.some(w => w.kCGWindowOwnerPID === pid && w.kCGWindowLayer === 0)) {
            if (!app.hide) throw new Error("Could not hide mpv");
            return;
        }
        delay(0.05);
    }
}
]]

local function restore_previous_app()
	if not background_requested
		or not mp.get_property_native("idle-active")
		or mp.get_property_native("vo-configured") then
		return
	end
	background_requested = false
	-- Native hide returns focus to the previous app without Accessibility permissions.
	mp.command_native_async({
		name = "subprocess",
		args = {
			"/usr/bin/osascript", "-l", "JavaScript", "-e", hide_if_windowless,
			tostring(mp.get_property_number("pid")),
		},
		playback_only = false,
		capture_stderr = true,
	}, function(success, result, error)
		if not success or result.status ~= 0 then
			msg.warn("Could not hide idle mpv: " .. tostring(error or (result and result.stderr)))
		end
	end)
end

local function background()
	background_requested = true
	mp.command("write-watch-later-config")
	mp.command("stop")
end

mp.observe_property("idle-active", "bool", restore_previous_app)
mp.observe_property("vo-configured", "bool", restore_previous_app)
mp.register_event("start-file", function()
	background_requested = false
end)

-- Only loaded by Yazi's idle player; Q and application quit remain unchanged.
mp.add_forced_key_binding("q", "yazi-background", background)
