import { Plugin } from "@opencode/plugin/tui"
import { installNotifications } from "./core.js"
import { readAttention } from "./settings.js"

export default Plugin.define({
  id: "opencode-kitty-session-notify",
  setup(context) {
    const notifications = installNotifications(context, readAttention)
    const testTimers = new Set()
    const publish = () => {
      const marker = Buffer.from(JSON.stringify({ version: "0.2.2", revision: context.options?.revision,
        instance: notifications.instance })).toString("base64")
      context.renderer.stdout.write(`\x1b]1337;SetUserVar=opencode_notify=${marker}\x07`)
    }
    publish()
    context.renderer.on("focus", publish)
    context.keymap.layer(() => ({
      commands: [{
        id: "kitty-notify.test",
        title: "Test clickable Kitty session notification",
        group: "Notifications",
        slash: { name: "kitty-notify-test", arguments: true },
        run: async (input) => {
          const route = context.ui.router.current()
          const sessionID = input?.trim() || (route.type === "session" ? route.sessionID : undefined)
          if (!sessionID) {
            context.ui.toast.show({ message: "Open a session first", variant: "warning" })
            return
          }
          context.ui.toast.show({ message: "Test notification in 3 seconds: switch to another pane or application" })
          const timer = setTimeout(() => {
            testTimers.delete(timer)
            void notifications.send(sessionID, "Notification click test", "default").catch(() => {})
          }, 3000)
          testTimers.add(timer)
        },
      }],
    }))
    return () => {
      for (const timer of testTimers) clearTimeout(timer)
      context.renderer.off("focus", publish)
      notifications.dispose()
      context.renderer.stdout.write("\x1b]1337;SetUserVar=opencode_notify=\x07")
    }
  },
})
