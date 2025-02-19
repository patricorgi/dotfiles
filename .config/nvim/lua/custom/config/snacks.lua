---@diagnostic disable: missing-fields
require('snacks').setup {
  notifier = {},
  picker = {
    matcher = { frecency = true, cwd_bonus = true, history_bonus = true },
    formatters = { icon_width = 3 },
    win = { input = { keys = { ['<Esc>'] = { 'close', mode = { 'n', 'i' } } } } },
  },
  dashboard = {
    preset = {
      keys = {
        { icon = '󰈞 ', key = 'f', desc = 'Find files', action = ':lua Snacks.picker.smart()' },
        { icon = ' ', key = 'o', desc = 'Find history', action = 'lua Snacks.picker.recent()' },
        { icon = ' ', key = 'e', desc = 'New file', action = ':enew' },
        { icon = ' ', key = 'o', desc = 'Recent files', action = ':lua Snacks.picker.recent()' },
        { icon = '󰒲 ', key = 'L', desc = 'Lazy', action = ':Lazy', enabled = package.loaded.lazy ~= nil },
        { icon = '󰔛 ', key = 'P', desc = 'Lazy Profile', action = ':Lazy profile', enabled = package.loaded.lazy ~= nil },
        { icon = ' ', key = 'M', desc = 'Mason', action = ':Mason', enabled = package.loaded.lazy ~= nil },
        { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
      },
      header = [[
░  ░░░░░░░░  ░░░░  ░░░      ░░░  ░░░░░░░
▒  ▒▒▒▒▒▒▒▒  ▒▒▒▒  ▒▒  ▒▒▒▒  ▒▒  ▒▒▒▒▒▒▒
▓  ▓▓▓▓▓▓▓▓        ▓▓  ▓▓▓▓▓▓▓▓       ▓▓
█  ████████  ████  ██  ████  ██  ████  █
█        ██  ████  ███      ███       ██
    ]],
    },
    sections = {
      { section = 'header' },
      { icon = ' ', title = 'Keymaps', section = 'keys', indent = 2, padding = 1 },
    },
  },
  image = {
    enabled = true,
    doc = { enabled = true, inline = false, float = true, max_width = 40, max_height = 30 },
    resolve = function(_, src)
      local vault_path = vim.fn.expand '~' .. '/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault'

      -- when the file path is *attachments/*
      local att_path = src:match '(attachments/.*)'
      if att_path then
        return vault_path .. '/' .. att_path
      end

      -- when the file path is pure basename without any directory component
      if not src:match '[/\\]' then
        return vault_path .. '/attachments/' .. src
      end

      -- when the file path is absolute path
      if src:match '^/' then
        return src
      end

      return src
    end,
  },
  indent = {
    indent = { enabled = false },
    animate = { duration = { step = 10, duration = 100 } },
    scope = { enabled = true, char = '┊', underline = false, only_current = true, priority = 1000 },
  },
  statuscolumn = {
    left = { 'mark', 'git' },
    right = { 'sign', 'fold' },
    folds = { open = true, git_hl = true },
    git = { patterns = { 'GitSign', 'MiniDiffSign' } },
  },
}

-- ---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
-- local progress = vim.defaulttable()
-- vim.api.nvim_create_autocmd('LspProgress', {
--   ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
--   callback = function(ev)
--     local client = vim.lsp.get_client_by_id(ev.data.client_id)
--     local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
--     if not client or type(value) ~= 'table' then
--       return
--     end
--     local p = progress[client.id]
--
--     for i = 1, #p + 1 do
--       if i == #p + 1 or p[i].token == ev.data.params.token then
--         p[i] = {
--           token = ev.data.params.token,
--           msg = ('[%3d%%] %s%s'):format(
--             value.kind == 'end' and 100 or value.percentage or 100,
--             value.title or '',
--             value.message and (' **%s**'):format(value.message) or ''
--           ),
--           done = value.kind == 'end',
--         }
--         break
--       end
--     end
--
--     local msg = {} ---@type string[]
--     progress[client.id] = vim.tbl_filter(function(v)
--       return table.insert(msg, v.msg) or not v.done
--     end, p)
--
--     local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
--     vim.notify(table.concat(msg, '\n'), 'info', {
--       id = 'lsp_progress',
--       title = client.name,
--       opts = function(notif)
--         notif.icon = #progress[client.id] == 0 and ' ' or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
--       end,
--     })
--   end,
-- })
