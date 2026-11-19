import { randomBytes } from "node:crypto"

const OSC = "\x1b]99;"
const ST = "\x1b\\"
const PREFIX = "ocn-"
const TTL = 10 * 60 * 1000
const MAX_PENDING = 128
const QUESTION_TYPE = "opencode.question"
const clean = (text) => String(text ?? "").replace(/[\x00-\x1f\x7f-\x9f]/g, " ").slice(0, 400)
const encoded = (text) => Buffer.from(clean(text)).toString("base64")
const unwrap = (response) => response?.data ?? response

export function questionBody(form) {
  const text = (value) => typeof value === "string" ? value.trim() : ""
  const fields = Array.isArray(form?.fields) ? form.fields : []
  const questions = fields.filter((field) => !field.hidden && field.type !== "external").map((field) =>
    [...new Set([text(field.title), text(field.description)].filter(Boolean))].join(" — ")
  ).filter(Boolean)
  return [...new Set(questions)].join(" / ") || text(form?.title) || "Question requires attention"
}

export function installNotifications(context, settings = () => ({ notifications: true, sound: false }), hooks = {}) {
  const { renderer, ui, data } = context
  if (typeof renderer.prependInputHandler !== "function" || typeof renderer.removeInputHandler !== "function") {
    throw new Error("Kitty session notifications require OpenTUI raw input handlers")
  }
  const instance = randomBytes(16).toString("hex")
  const pending = new Map()
  const seen = new Set()
  const inputs = new Map()
  const executions = new Map()
  const write = hooks.write ?? ((sequence) => renderer.stdout.write(sequence))
  const now = hooks.now ?? Date.now
  let disposed = false

  function close(identifier) {
    write(`${OSC}i=${identifier}:p=close;${ST}`)
    pending.delete(identifier)
  }

  function prune() {
    for (const [identifier, notice] of pending) {
      if (notice.expires <= now()) close(identifier)
    }
    while (pending.size >= MAX_PENDING) close(pending.keys().next().value)
  }

  function owns(sessionID) {
    const open = new Set(ui.tabs.list().map((tab) => tab.sessionID))
    const route = ui.router.current()
    if (route.type === "session") open.add(route.sessionID)
    return open.has(sessionID) || open.has(data.session.root(sessionID))
  }

  function remember(map, key, value) {
    map.set(key, value)
    if (map.size > 512) map.delete(map.keys().next().value)
  }

  function inputOrigin(message) {
    if (message?.type === "user") return "user"
    if (message?.type === "synthetic") return message.metadata?.source === "subagent" ? "subagent" : "other"
    return "unknown"
  }

  async function isAutomaticSubagentReport(sessionID, presentation) {
    if (presentation.origin && presentation.origin !== "unknown") return presentation.origin === "subagent"
    // Handles a plugin reload in the middle of an execution, when its first
    // inbox-delivery event was missed. Do not inspect or forward message text.
    const response = unwrap(await context.client.session.message.list({ sessionID, limit: 100, order: "desc" }))
    const messages = Array.isArray(response) ? response : response?.data
    if (!Array.isArray(messages)) throw new Error("Could not determine notification input origin")
    const input = messages.filter((message) =>
      (message.type === "user" || message.type === "synthetic") &&
      (!presentation.completedAt || message.time?.created <= presentation.completedAt)
    ).sort((a, b) => (b.time?.created ?? 0) - (a.time?.created ?? 0))[0]
    return inputOrigin(input) === "subagent"
  }

  async function send(sessionID, message, sound = "done", presentation = {}) {
    const preferences = settings()
    if (disposed || !sessionID || (!preferences.notifications && !preferences.sound)) return null
    // Fetch before using a title: an event's session need not be cached by this TUI.
    let session
    try {
      session = data.session.get(sessionID)
      if (presentation.mainOnly) {
        if (session?.parentID) return null
        session = unwrap(await context.client.session.get({ sessionID }))
        // A child finishing must not announce that its still-running parent is done.
        if (session?.id !== sessionID || session.parentID) return null
        // A child's automatic report can start a new execution in the parent.
        if (await isAutomaticSubagentReport(sessionID, presentation)) return null
      } else if (!session?.title) {
        await data.session.sync(sessionID)
        session = data.session.get(sessionID)
      }
      if (!session) session = unwrap(await context.client.session.get({ sessionID }))
    } catch {
      return null
    }
    if (disposed || !owns(sessionID)) return null
    if (preferences.sound) {
      void context.attention.notify({ sound: { name: sound, when: "always" } }).catch(() => {})
    }
    if (!preferences.notifications) return null
    prune()
    const identifier = `${PREFIX}${instance}-${randomBytes(16).toString("hex")}`
    const sessionTitle = session.title || sessionID
    const title = presentation.title || sessionTitle
    const type = presentation.type ? `:t=${encoded(presentation.type)}` : ""
    const body = presentation.type === QUESTION_TYPE ? `${sessionTitle} · ${sessionID}` : `${message} · ${sessionID}`
    pending.set(identifier, { sessionID, expires: now() + TTL })
    try {
      write(`${OSC}i=${identifier}:d=0:a=focus,report:o=unfocused:f=T3BlbkNvZGU=:s=c2lsZW50:w=${TTL}${type}:e=1;${encoded(title)}${ST}`)
      write(`${OSC}i=${identifier}:p=body:e=1;${encoded(body)}${ST}`)
    } catch (error) {
      pending.delete(identifier)
      throw error
    }
    hooks.sent?.({ identifier, sessionID, title, message })
    return identifier
  }

  async function activate(identifier) {
    const notice = pending.get(identifier)
    pending.delete(identifier)
    if (disposed || !notice || notice.expires <= now()) return
    try {
      // Confirm it still exists. Never create a new session for an old notification.
      const session = unwrap(await context.client.session.get({ sessionID: notice.sessionID }))
      if (disposed || session?.id !== notice.sessionID) return
      await data.session.sync(notice.sessionID)
      if (disposed) return
      if (ui.tabs.enabled()) await ui.tabs.focus(notice.sessionID)
      else await ui.router.navigate({ type: "session", sessionID: notice.sessionID })
      hooks.activated?.({ identifier, sessionID: notice.sessionID })
    } catch {
      if (!disposed) ui.toast.show({ title: "OpenCode", message: "Notification session is no longer available", variant: "warning" })
    }
  }

  function input(sequence) {
    if (!sequence.startsWith(OSC) || !sequence.includes(`i=${PREFIX}`)) return false
    // Consume our namespace even for stale/foreign IDs; never insert replies as text.
    const match = /^\x1b\]99;i=(ocn-[0-9a-f]{32}-[0-9a-f]{32});(?:0)?(?:\x1b\\|\x07)$/.exec(sequence)
    if (match) void activate(match[1])
    return true
  }

  renderer.prependInputHandler(input)
  const stops = []
  const observe = (type, callback) => {
    stops.push(data.on(type, (event) => {
      if (seen.has(event.id)) return
      seen.add(event.id)
      if (seen.size > 512) seen.delete(seen.values().next().value)
      callback(event)
    }))
  }
  observe("session.inbox.enqueued", (event) => {
    const { inboxID, item } = event.data
    remember(inputs, inboxID, inputOrigin({ type: item?.type, metadata: item?.payload?.metadata }))
  })
  observe("session.execution.started", (event) => remember(executions, event.data.sessionID, {}))
  observe("session.inbox.delivered", (event) => {
    const { sessionID, inboxID } = event.data
    let execution = executions.get(sessionID)
    if (!execution) remember(executions, sessionID, execution = {})
    // Only the first delivered input starts this turn. Later steering or child
    // reports must not silence a turn that the user originally requested.
    execution.origin ??= inputs.get(inboxID) ?? "unknown"
    inputs.delete(inboxID)
  })
  const completion = (event) => {
    const { sessionID } = event.data
    const origin = executions.get(sessionID)?.origin
    executions.delete(sessionID)
    return { mainOnly: true, origin, completedAt: event.created }
  }
  const subscribe = (type, message, sound, getID = (event) => event.data.sessionID, presentation = () => ({})) =>
    observe(type, (event) => { void send(getID(event), message, sound, presentation(event)).catch(() => {}) })
  subscribe("session.execution.succeeded", "Session done", "done", undefined, completion)
  subscribe("session.execution.failed", "Session failed", "error", undefined, completion)
  subscribe("permission.asked", "Permission required", "permission")
  subscribe("form.created", "Question requires attention", "question", (event) => event.data.form.sessionID,
    (event) => ({ title: questionBody(event.data.form), type: QUESTION_TYPE }))

  function dispose() {
    disposed = true
    for (const stop of stops) stop()
    renderer.removeInputHandler(input)
    for (const identifier of [...pending.keys()]) close(identifier)
    seen.clear()
    inputs.clear()
    executions.clear()
  }

  return { send, input, dispose, instance }
}
