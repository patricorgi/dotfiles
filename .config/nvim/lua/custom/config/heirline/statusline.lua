local utils = require 'heirline.utils'
local conditions = require 'heirline.conditions'
local palette = require('catppuccin.palettes').get_palette 'mocha'
local icons = require 'custom.ui.icons'
local colors = {
  diag_warn = utils.get_highlight('DiagnosticWarn').fg,
  diag_error = utils.get_highlight('DiagnosticError').fg,
  diag_hint = utils.get_highlight('DiagnosticHint').fg,
  diag_info = utils.get_highlight('DiagnosticInfo').fg,
  git_del = utils.get_highlight('diffDeleted').fg,
  git_add = utils.get_highlight('diffAdded').fg,
  git_change = utils.get_highlight('diffChanged').fg,
}
-- Spacing providers
local Spacer = { provider = ' ' }
local Fill = { provider = '%=' }
local function RightPadding(child, num_space)
  local result = {
    condition = child.condition,
    child,
    Spacer,
  }
  if num_space ~= nil then
    for _ = 2, num_space do
      table.insert(result, Spacer)
    end
  end
  return result
end

local Mode = {
  -- get vim current mode, this information will be required by the provider
  -- and the highlight functions, so we compute it only once per component
  -- evaluation and store it as a component attribute
  init = function(self)
    self.mode = vim.fn.mode(1) -- :h mode()
  end,
  -- Now we define some dictionaries to map the output of mode() to the
  -- corresponding string and color. We can put these into `static` to compute
  -- them at initialisation time.
  static = {
    mode_names = { -- change the strings if you like it vvvvverbose!
      n = '',
      no = '?',
      nov = '?',
      noV = '?',
      ['no\22'] = '?',
      niI = 'i',
      niR = 'r',
      niV = 'Nv',
      nt = '',
      v = '',
      vs = 'Vs',
      V = '-',
      Vs = 'Vs',
      ['\22'] = '\\',
      ['\22s'] = '\\',
      s = 'S',
      S = 'S_',
      ['\19'] = '^S',
      i = '',
      ic = 'Ic',
      ix = 'Ix',
      R = 'R',
      Rc = 'Rc',
      Rx = 'Rx',
      Rv = 'Rv',
      Rvc = 'Rv',
      Rvx = 'Rv',
      c = '',
      cv = 'Ex',
      r = '...',
      rm = 'M',
      ['r?'] = '?',
      ['!'] = '!',
      t = '',
    },
    mode_colors = {
      n = palette.blue,
      i = palette.green,
      v = palette.mauve,
      V = palette.mauve,
      ['\22'] = palette.mauve,
      c = palette.red,
      s = palette.pink,
      S = palette.pink,
      ['\19'] = palette.pink,
      R = palette.peach,
      r = palette.peach,
      ['!'] = palette.red,
      t = palette.lavender,
    },
  },
  -- We can now access the value of mode() that, by now, would have been
  -- computed by `init()` and use it to index our strings dictionary.
  -- note how `static` fields become just regular attributes once the
  -- component is instantiated.
  -- To be extra meticulous, we can also add some vim statusline syntax to
  -- control the padding and make sure our string is always at least 2
  -- characters long. Plus a nice Icon.
  provider = function(self)
    return '%1(' .. self.mode_names[self.mode] .. '%)'
  end,
  -- Same goes for the highlight. Now the foreground will change according to the current mode.
  hl = function(self)
    local mode = self.mode:sub(1, 1) -- get only the first mode character
    return { fg = palette.base, bg = self.mode_colors[mode], bold = true }
  end,
  -- Re-evaluate the component only on ModeChanged event!
  -- Also allows the statusline to be re-evaluated when entering operator-pending mode
  update = {
    'ModeChanged',
    pattern = '*:*',
    callback = vim.schedule_wrap(function()
      vim.cmd 'redrawstatus'
    end),
  },
}

-- smart workdir
local WorkDir = {
  init = function(self)
    self.icon = '󰙅 '
    local cwd = vim.fn.getcwd(0)
    self.cwd = vim.fn.fnamemodify(cwd, ':t')
  end,
  hl = { fg = 'fg', bold = false },

  flexible = 1,

  {
    provider = function(self)
      return self.icon .. self.cwd
    end,
  },
  {
    -- evaluates to the shortened path
    provider = function(self)
      local cwd = vim.fn.pathshorten(self.cwd)
      return self.icon .. cwd
    end,
  },
}

-- Git
local Git = {
  condition = conditions.is_git_repo,

  init = function(self)
    self.status_dict = vim.b.gitsigns_status_dict
    self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
  end,

  hl = { fg = palette.flamingo },

  { -- git branch name
    provider = function(self)
      return ' ' .. self.status_dict.head
    end,
    hl = { bold = true },
  },
  -- You could handle delimiters, icons and counts similar to Diagnostics
  {
    condition = function(self)
      return self.has_changes
    end,
    provider = '(',
  },
  {
    provider = function(self)
      local count = self.status_dict.added or 0
      return count > 0 and ('+' .. count)
    end,
    hl = { fg = colors.git_add },
  },
  {
    provider = function(self)
      local count = self.status_dict.removed or 0
      return count > 0 and ('-' .. count)
    end,
    hl = { fg = colors.git_del },
  },
  {
    provider = function(self)
      local count = self.status_dict.changed or 0
      return count > 0 and ('~' .. count)
    end,
    hl = { fg = colors.git_change },
  },
  {
    condition = function(self)
      return self.has_changes
    end,
    provider = ')',
  },
}

-- Dianostics
local Diagnostics = {

  condition = conditions.has_diagnostics,

  static = {
    error_icon = icons.diagnostics.Error,
    warn_icon = icons.diagnostics.Warn,
    info_icon = icons.diagnostics.Info,
    hint_icon = icons.diagnostics.Hint,
  },

  init = function(self)
    self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
  end,

  update = { 'DiagnosticChanged', 'BufEnter' },

  {
    provider = function(self)
      -- 0 is just another output, we can decide to print it or not!
      return self.errors > 0 and (self.error_icon .. self.errors .. ' ')
    end,
    hl = { fg = colors.diag_error },
  },
  {
    provider = function(self)
      return self.warnings > 0 and (self.warn_icon .. self.warnings .. ' ')
    end,
    hl = { fg = colors.diag_warn },
  },
  {
    provider = function(self)
      return self.info > 0 and (self.info_icon .. self.info .. ' ')
    end,
    hl = { fg = colors.diag_info },
  },
  {
    provider = function(self)
      return self.hints > 0 and (self.hint_icon .. self.hints)
    end,
    hl = { fg = colors.diag_hint },
  },
} -- Diagnostics

local MacroRecording = {
  condition = conditions.is_active,
  init = function(self)
    self.reg_recording = vim.fn.reg_recording()
    self.status_dict = vim.b.gitsigns_status_dict or { added = 0, removed = 0, changed = 0 }
    self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
  end,
  {
    condition = function(self)
      return self.reg_recording ~= ''
    end,
    {
      provider = '󰻃 ',
      hl = { fg = palette.maroon },
    },
    {
      provider = function(self)
        return self.reg_recording
      end,
      hl = { fg = palette.maroon, italic = false, bold = true },
    },
    hl = { fg = palette.text, bg = palette.base },
  },
  update = { 'RecordingEnter', 'RecordingLeave' },
} -- MacroRecording

local LSPActive = {
  condition = conditions.lsp_attached,
  update = { 'LspAttach', 'LspDetach' },
  provider = function()
    local names = {}
    ---@diagnostic disable-next-line: deprecated
    for _, server in pairs(vim.lsp.get_active_clients { bufnr = 0 }) do
      table.insert(names, server.name)
    end
    return table.concat(names, ',')
  end,
  hl = { fg = palette.surface1, bold = false },
}

local FileType = {
  provider = function()
    return vim.bo.filetype
  end,
  hl = { fg = utils.get_highlight('Type').fg, bold = true },
}
-- overseer
local function OverseerTasksForStatus(st)
  return {
    condition = function(self)
      return self.tasks[st]
    end,
    provider = function(self)
      return string.format('%s%d', self.symbols[st], #self.tasks[st])
    end,
    hl = function(_)
      return {
        fg = utils.get_highlight(string.format('Overseer%s', st)).fg,
      }
    end,
  }
end
local Overseer = {
  condition = function()
    return package.loaded.overseer
  end,
  init = function(self)
    local tasks = require('overseer.task_list').list_tasks { unique = true }
    local tasks_by_status = require('overseer.util').tbl_group_by(tasks, 'status')
    self.tasks = tasks_by_status
  end,
  static = {
    symbols = {
      ['CANCELED'] = ' 􀕧 ',
      ['FAILURE'] = ' 􀁐 ',
      ['SUCCESS'] = ' 􀁢 ',
      ['RUNNING'] = ' 􁾤 ',
    },
  },
  RightPadding(OverseerTasksForStatus 'CANCELED'),
  RightPadding(OverseerTasksForStatus 'RUNNING'),
  RightPadding(OverseerTasksForStatus 'SUCCESS'),
  RightPadding(OverseerTasksForStatus 'FAILURE'),
}
local Ruler = {
  -- %l = current line number
  -- %L = number of lines in the buffer
  -- %c = column number
  -- %P = percentage through file of displayed window
  provider = '%(%l/%L%)(%P)',
}

local ScrollBar = {
  static = {
    sbar = { '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█' },
  },
  provider = function(self)
    local curr_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_line_count(0)
    local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
    return string.rep(self.sbar[i], 2)
  end,
  hl = { fg = palette.yellow, bg = palette.base },
}

return { -- statusline
  RightPadding(Mode, 2),
  RightPadding(WorkDir, 2),
  RightPadding(Git, 2),
  RightPadding(Diagnostics),
  Fill,
  MacroRecording,
  Fill,
  RightPadding(LSPActive),
  RightPadding(FileType, 0),
  RightPadding(Overseer, 0),
  RightPadding(Ruler),
  ScrollBar,
}
