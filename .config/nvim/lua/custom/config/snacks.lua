---@diagnostic disable: missing-fields
require('snacks').setup {
  styles = { notification = { border = 'single' }, notification_history = { border = 'single', width = 0.9, height = 0.9, minimal = true } },
  indent = {
    indent = {
      char = ' ',
      only_scope = true,
      only_current = true,
      hl = {
        'SnacksIndent1',
        'SnacksIndent2',
        'SnacksIndent3',
        'SnacksIndent4',
        'SnacksIndent5',
        'SnacksIndent6',
        'SnacksIndent7',
        'SnacksIndent8',
      },
    },
    animate = {
      duration = {
        step = 10,
        duration = 100,
      },
    },
    scope = {
      enabled = true, -- enable highlighting the current scope
      priority = 200,
      char = '┊',
      underline = false, -- underline the start of the scope
      only_current = true, -- only show scope in the current window
      hl = {
        'SnacksIndent1',
        'SnacksIndent2',
        'SnacksIndent3',
        'SnacksIndent4',
        'SnacksIndent5',
        'SnacksIndent6',
        'SnacksIndent7',
        'SnacksIndent8',
      },
    },
  },
  lazygit = {},
  notifier = {},
  bufdelete = {},
  dashboard = {
    preset = {
      keys = {
        {
          icon = '󰈞 ',
          key = 'f',
          desc = 'Find files',
          action = function()
            require('telescope.builtin').find_files()
          end,
        },
        {
          icon = ' ',
          key = 'o',
          desc = 'Find history',
          action = function()
            require('telescope.builtin').oldfiles()
          end,
        },
        { icon = ' ', key = 'n', desc = 'New file', action = ':enew' },
        { icon = ' ', key = 'c', desc = 'Config', action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
        { icon = '󰒲 ', key = 'L', desc = 'Lazy', action = ':Lazy', enabled = package.loaded.lazy ~= nil },
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
      { icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
      { icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
      -- { section = 'startup' },
    },
  },
  statuscolumn = {
    folds = {
      open = true, -- show open fold icons
      git_hl = false, -- use Git Signs hl for fold icons
    },
  },
}

---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
local progress = vim.defaulttable()
vim.api.nvim_create_autocmd('LspProgress', {
  ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
    if not client or type(value) ~= 'table' then
      return
    end
    local p = progress[client.id]

    for i = 1, #p + 1 do
      if i == #p + 1 or p[i].token == ev.data.params.token then
        p[i] = {
          token = ev.data.params.token,
          msg = ('[%3d%%] %s%s'):format(
            value.kind == 'end' and 100 or value.percentage or 100,
            value.title or '',
            value.message and (' **%s**'):format(value.message) or ''
          ),
          done = value.kind == 'end',
        }
        break
      end
    end

    local msg = {} ---@type string[]
    progress[client.id] = vim.tbl_filter(function(v)
      return table.insert(msg, v.msg) or not v.done
    end, p)

    local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
    vim.notify(table.concat(msg, '\n'), 'info', {
      id = 'lsp_progress',
      title = client.name,
      opts = function(notif)
        notif.icon = #progress[client.id] == 0 and ' ' or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
      end,
    })
  end,
})
