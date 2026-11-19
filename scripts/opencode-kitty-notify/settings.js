import { readFileSync } from "node:fs"
import { homedir } from "node:os"
import { join } from "node:path"

export function readAttention(env = process.env) {
  const path = join(env.XDG_CONFIG_HOME || join(homedir(), ".config"), "opencode", "cli.json")
  let disk = {}
  try {
    disk = JSON.parse(readFileSync(path, "utf8"))
  } catch (error) {
    if (error.code !== "ENOENT") return { notifications: false, sound: false }
  }
  let inline = {}
  try {
    inline = JSON.parse(env.OPENCODE_CLI_CONFIG_CONTENT || "{}")
  } catch {
    return { notifications: false, sound: false }
  }
  const attention = { ...disk.attention, ...inline.attention }
  return { notifications: attention.notifications !== false, sound: attention.sound === true }
}
