local palette = require('catppuccin.palettes').get_palette 'mocha'
local utils = require 'heirline.utils'
local conditions = require 'heirline.conditions'
local icons = require 'config.icons'
local colors = {
    diag_warn = utils.get_highlight('DiagnosticWarn').fg,
    diag_error = utils.get_highlight('DiagnosticError').fg,
    diag_hint = utils.get_highlight('DiagnosticHint').fg,
    diag_info = utils.get_highlight('DiagnosticInfo').fg,
    git_del = utils.get_highlight('diffDeleted').fg,
    git_add = utils.get_highlight('diffAdded').fg,
    git_change = utils.get_highlight('diffChanged').fg,
}
local dim_color = palette.surface1
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

local M = {}
M.Spacer = { provider = ' ' }
M.Fill = { provider = '%=' }
M.Ruler = {
    -- %l = current line number
    -- %L = number of lines in the buffer
    -- %c = column number
    -- %P = percentage through file of displayed window
    provider = '%4l,%-3c %P',
}
M.ScrollBar = {
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

-- Spacing providers
M.RightPadding = function(child, num_space)
    local result = {
        condition = child.condition,
        child,
    }
    if num_space ~= nil then
        for _ = 1, num_space do
            table.insert(result, M.Spacer)
        end
    end
    return result
end
M.Mode = {
    init = function(self)
        self.mode = vim.fn.mode(1)
    end,
    static = {
        mode_names = { -- change the strings if you like it vvvvverbose!
            n = 'NORMAL',
            no = '?',
            nov = '?',
            noV = '?',
            ['no\22'] = '?',
            niI = 'i',
            niR = 'r',
            niV = 'Nv',
            nt = 'N-TERM',
            v = 'VISUAL',
            vs = 'Vs',
            V = 'V-LINE',
            Vs = 'Vs',
            ['\22'] = 'VBLOCK',
            ['\22s'] = '\\',
            s = 'SELECT',
            S = 'S-LINE',
            ['\19'] = '^S',
            i = 'INSERT',
            ic = 'Ic',
            ix = 'Ix',
            R = 'RPLACE',
            Rc = 'Rc',
            Rx = 'Rx',
            Rv = 'V-RPLC',
            Rvc = 'Rv',
            Rvx = 'Rv',
            c = '',
            cv = 'Ex',
            r = '...',
            rm = 'M',
            ['r?'] = '?',
            ['!'] = '!',
            t = 'TERM',
        },
        mode_colors = {
            n = dim_color,
            nt = dim_color,

            i = palette.blue,
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
            t = palette.blue,
        },
    },
    provider = function(self)
        return ' ' .. '%1(' .. self.mode_names[self.mode] .. '%)' .. ' ▍'
    end,
    hl = function(self)
        local mode = self.mode:sub(1, 1) -- get only the first mode character
        return { fg = palette.base, bg = self.mode_colors[mode], bold = true }
    end,
    update = {
        'ModeChanged',
        pattern = '*:*',
        callback = vim.schedule_wrap(function()
            pcall(vim.cmd, 'redrawstatus')
        end),
    },
}

M.MacroRecording = {
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

M.Formatters = {
    condition = function(self)
        local ok, conform = pcall(require, 'conform')
        self.conform = conform
        return ok
    end,
    update = { 'BufEnter' },
    provider = function(self)
        local ft_entry = self.conform.formatters_by_ft[vim.bo.filetype]
        local ft_formatters
        if type(ft_entry) == 'function' then
            ft_formatters = ft_entry()
        else
            ft_formatters = ft_entry
        end
        return ft_formatters and table.concat(ft_formatters, ',') or ''
    end,
    hl = { fg = dim_color, bold = false },
}

M.LSPActive = {
    condition = conditions.lsp_attached,
    update = { 'LspAttach', 'LspDetach' },
    provider = function()
        local names = {}
        ---@diagnostic disable-next-line: deprecated
        for _, server in pairs(vim.lsp.get_clients { bufnr = 0 }) do
            table.insert(names, server.name)
        end
        return table.concat(names, ',')
    end,
    hl = { fg = dim_color, bold = false },
    -- on_click = {
    --   name = 'heirline_lsp',
    --   callback = function()
    --     vim.cmd 'LspInfo'
    --   end,
    -- },
}

M.FileType = {
    provider = function()
        return vim.bo.filetype
    end,
    hl = { fg = utils.get_highlight('Type').fg, bold = true },
}

M.CodeiumStatus = {
    init = function(self)
        self.codeium_exist = vim.fn.exists '*codeium#GetStatusString' == 1
        self.codeium_status = self.codeium_exist and vim.fn['codeium#GetStatusString']() or nil
    end,
    provider = function(self)
        if not self.codeium_exist then
            return ''
        end
        if self.codeium_status == ' ON' then
            return '󰚩 '
        elseif self.codeium_status == ' OFF' then
            return '󱚡 '
        else
            return '󱚝 '
        end
    end,
    hl = function(self)
        if self.codeium_status == ' ON' then
            return { fg = palette.green }
        elseif self.codeium_status == ' OFF' then
            return { fg = palette.gray }
        else
            return { fg = palette.maroon }
        end
    end,
}

-- Git
M.Git = {
    condition = conditions.is_git_repo,

    init = function(self)
        self.status_dict = vim.b.gitsigns_status_dict
        self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
    end,

    hl = function(self)
        return { fg = self.has_changes and palette.maroon or dim_color }
    end,

    { -- git branch name
        provider = function(self)
            if self.has_changes then
                return '󰘬 ' .. self.status_dict.head .. '*'
            else
                return '󰘬 ' .. self.status_dict.head
            end
        end,
    },
    -- {
    --   condition = function(self)
    --     return self.has_changes
    --   end,
    --   provider = '(',
    -- },
    -- {
    --   provider = function(self)
    --     local count = self.status_dict.added or 0
    --     return count > 0 and ('+' .. count)
    --   end,
    --   hl = { fg = colors.git_add },
    -- },
    -- {
    --   provider = function(self)
    --     local count = self.status_dict.removed or 0
    --     return count > 0 and ('-' .. count)
    --   end,
    --   hl = { fg = colors.git_del },
    -- },
    -- {
    --   provider = function(self)
    --     local count = self.status_dict.changed or 0
    --     return count > 0 and ('~' .. count)
    --   end,
    --   hl = { fg = colors.git_change },
    -- },
    -- {
    --   condition = function(self)
    --     return self.has_changes
    --   end,
    --   provider = ')',
    -- },
    -- on_click = {
    --   name = 'heirline_git',
    --   callback = function()
    --     ---@diagnostic disable-next-line: missing-fields
    --     Snacks.lazygit { cwd = Snacks.git.get_root() }
    --   end,
    -- },
}

-- Dianostics
M.Diagnostics = {
    condition = conditions.has_diagnostics,
    static = {
        error_icon = icons.diagnostics.Error .. ' ',
        warn_icon = icons.diagnostics.Warn .. ' ',
        info_icon = icons.diagnostics.Info .. ' ',
        hint_icon = icons.diagnostics.Hint .. ' ',
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
    -- on_click = {
    --   name = 'heirline_diagnostic',
    --   callback = function()
    --     Snacks.picker.diagnostics_buffer()
    --   end,
    -- },
} -- Diagnostics

M.FileIcon = {
    condition = function(self)
        return vim.fn.fnamemodify(self.filename, ':.') ~= ''
    end,
    init = function(self)
        self.is_modified = vim.api.nvim_get_option_value('modified', { buf = self.bufnr })
        local filename = self.filename
        local extension = vim.fn.fnamemodify(filename, ':e')
        local icon, hl, _ = MiniIcons.get('file', 'file.' .. extension)
        local bt = vim.api.nvim_get_option_value('buftype', { buf = self.bufnr }) or nil
        if bt and bt == 'terminal' then
            icon = ''
        end
        self.icon = icon
        self.icon_color = string.format('#%06x', vim.api.nvim_get_hl(0, { name = hl })['fg'])
    end,
    provider = function(self)
        return self.icon and (self.icon .. ' ')
    end,
    hl = function(self)
        return { fg = self.is_modified and self.icon_color or dim_color }
    end,
}
-- we redefine the filename component, as we probably only want the tail and not the relative path
M.FileName = {
    init = function(self)
        self.is_modified = vim.api.nvim_get_option_value('modified', { buf = self.bufnr })
        local filename = self.filename
        local extension = vim.fn.fnamemodify(filename, ':e')
        local _, hl, _ = MiniIcons.get('file', 'file.' .. extension)
        self.icon_color = string.format('#%06x', vim.api.nvim_get_hl(0, { name = hl })['fg'])
    end,
    provider = function(self)
        -- self.filename will be defined later, just keep looking at the example!
        local filename = self.filename
        filename = filename == '' and vim.bo.filetype or vim.fn.fnamemodify(filename, ':t')
        return '' .. filename .. ''
    end,
    hl = function(self)
        return {
            -- fg = self.is_modified and palette.yellow or palette.surface2,
            fg = self.is_modified and self.icon_color or dim_color,
            italic = self.is_modified,
        }
    end,
}

-- we redefine the filename component, as we probably only want the tail and not the relative path
M.FilePath = {
    provider = function(self)
        -- first, trim the pattern relative to the current directory. For other
        -- options, see :h filename-modifers
        local filename = vim.fn.fnamemodify(self.filename, ':.')
        if filename == '' then
            return vim.bo.filetype ~= '' and vim.bo.filetype or vim.bo.buftype
        end
        -- now, if the filename would occupy more than 1/4th of the available
        -- space, we trim the file path to its initials
        -- See Flexible Components section below for dynamic truncation
        -- if not conditions.width_percent_below(#filename, 0.25) then
        --   filename = vim.fn.pathshorten(filename, 4)
        -- end
        return filename
    end,
    hl = function(self)
        return {
            fg = self.is_active and palette.text or palette.subtext0,
            bold = self.is_active or self.is_visible,
            italic = self.is_active,
        }
    end,
}

-- this looks exactly like the FileFlags component that we saw in
-- #crash-course-part-ii-filename-and-friends, but we are indexing the bufnr explicitly
-- also, we are adding a nice icon for terminal buffers.
M.FileFlags = {
    {
        init = function(self)
            local filename = self.filename
            local extension = vim.fn.fnamemodify(filename, ':e')
            local _, hl, _ = MiniIcons.get('file', 'file.' .. extension)
            self.icon_color = string.format('#%06x', vim.api.nvim_get_hl(0, { name = hl })['fg'])
        end,
        condition = function(self)
            local ignored_filetypes = {
                'dap-repl',
            }
            local result = vim.fn.fnamemodify(self.filename, ':.') ~= '' and
            vim.api.nvim_get_option_value('modified', { buf = self.bufnr })
            local ft = vim.api.nvim_get_option_value('buftype', { buf = self.bufnr })
            if vim.tbl_contains(ignored_filetypes, ft) then
                result = false
            end
            return result
        end,
        provider = ' 􀴥 ',
        hl = function(self)
            return { fg = self.icon_color, bold = self.is_active }
        end,
    },
    {
        condition = function(self)
            return not vim.api.nvim_get_option_value('modifiable', { buf = self.bufnr }) or
            vim.api.nvim_get_option_value('readonly', { buf = self.bufnr })
        end,
        provider = function(self)
            if vim.api.nvim_get_option_value('buftype', { buf = self.bufnr }) == 'terminal' then
                return ''
            else
                return ' '
            end
        end,
        hl = { fg = palette.text },
    },
}

M.Overseer = {
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
    M.RightPadding(OverseerTasksForStatus 'CANCELED'),
    M.RightPadding(OverseerTasksForStatus 'RUNNING'),
    M.RightPadding(OverseerTasksForStatus 'SUCCESS'),
    M.RightPadding(OverseerTasksForStatus 'FAILURE'),
}

M.FileNameBlock = {
    init = function(self)
        local bufnr = self.bufnr and self.bufnr or 0
        self.filename = vim.api.nvim_buf_get_name(bufnr)
    end,
    hl = { fg = palette.text },
    M.FileIcon,
    M.FileName,
    M.FileFlags,
}

M.FilePathBlock = {
    init = function(self)
        local bufnr = self.bufnr and self.bufnr or 0
        self.filename = vim.api.nvim_buf_get_name(bufnr)
    end,
    hl = { fg = palette.text },
    M.FileIcon,
    M.FileName,
    M.FileFlags,
}

M.TablineFileNameBlock = vim.tbl_extend('force', M.FileNameBlock, {
    on_click = {
        callback = function(_, minwid, _, button)
            if button == 'm' then -- close on mouse middle click
                vim.schedule(function()
                    vim.api.nvim_buf_delete(minwid, { force = false })
                end)
            else
                vim.api.nvim_win_set_buf(0, minwid)
            end
        end,
        minwid = function(self)
            return self.bufnr
        end,
        name = 'heirline_tabline_buffer_callback',
    },
})

vim.opt.showcmdloc = 'statusline'
M.ShowCmd = {
    condition = function()
        return vim.o.cmdheight == 0
    end,
    provider = '%3.5(%S%)',
}

M.SearchOccurrence = {
    condition = function()
        return vim.v.hlsearch == 1
    end,
    hl = { fg = palette.sky },
    provider = function()
        local sinfo = vim.fn.searchcount { maxcount = 0 }
        local search_stat = sinfo.incomplete > 0 and ' [?/?]' or
        sinfo.total > 0 and (' [%s/%s]'):format(sinfo.current, sinfo.total) or ''
        return search_stat
    end,
}

M.SimpleIndicator = {
    condition = function()
        return vim.g.simple_indicator_on
    end,
    hl = { fg = palette.sky },
    provider = '',
}

M.LspProgress = {
    provider = function()
        return require('lsp-progress').progress {
            format = function(messages)
                local active_clients = vim.lsp.get_clients()
                local client_count = #active_clients

                if #messages > 0 then
                    return table.concat(messages, ' ')
                end

                if client_count <= 0 then
                    return client_count
                else
                    local name_set = {}
                    local client_names = {}

                    for _, client in ipairs(active_clients) do
                        if client and client.name ~= '' and not name_set[client.name] then
                            name_set[client.name] = true
                            table.insert(client_names, '[' .. client.name .. ']')
                        end
                    end

                    return table.concat(client_names, ' ')
                end
            end,
        }
    end,
    update = {
        'User',
        pattern = 'LspProgressStatusUpdated',
        callback = vim.schedule_wrap(function()
            vim.cmd 'redrawstatus'
        end),
    },
    hl = { fg = dim_color, bold = false },
}

return M
