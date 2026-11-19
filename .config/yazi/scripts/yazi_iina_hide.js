ObjC.import("AppKit");
ObjC.import("CoreGraphics");

function run(argv) {
    const pid = Number(argv[0]);
    if (!Number.isSafeInteger(pid) || pid <= 0) throw new Error("Invalid IINA PID");
    const app = $.NSRunningApplication.runningApplicationWithProcessIdentifier(pid);
    // Allow the native close/fullscreen animation to finish, but never hide other windows.
    for (let attempt = 0; attempt < 30; attempt++) {
        if (app.isNil() || app.terminated || !app.active) return;
        const windows = ObjC.deepUnwrap(ObjC.castRefToObject($.CGWindowListCopyWindowInfo(
            $.kCGWindowListOptionOnScreenOnly | $.kCGWindowListExcludeDesktopElements,
            $.kCGNullWindowID
        )));
        if (!windows.some(window => window.kCGWindowOwnerPID === pid)) {
            if (!app.hide) throw new Error("Could not hide idle IINA");
            return;
        }
        delay(0.05);
    }
}
