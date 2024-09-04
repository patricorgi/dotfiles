local function getTelescopeOpts(state, path)
  return {
    cwd = path,
    search_dirs = { path },
    attach_mappings = function(prompt_bufnr, _)
      local actions = require 'telescope.actions'
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local action_state = require 'telescope.actions.state'
        local selection = action_state.get_selected_entry()
        local filename = selection.filename
        if filename == nil then
          filename = selection[1]
        end
        -- any way to open the file without triggering auto-close event of neo-tree?
        require('neo-tree.sources.filesystem').navigate(state, state.path, filename, function() end)
      end)
      return true
    end,
  }
end

vim.keymap.set('n', 'B', '<cmd>Neotree toggle<cr>', { desc = 'Toggle Neotree' })
local icons = require 'custom.ui.icons'
vim.fn.sign_define('DiagnosticSignError', { text = icons.diagnostics.Error, texthl = 'DiagnosticSignError' })
vim.fn.sign_define('DiagnosticSignWarn', { text = icons.diagnostics.Warn, texthl = 'DiagnosticSignWarn' })
vim.fn.sign_define('DiagnosticSignInfo', { text = icons.diagnostics.Info, texthl = 'DiagnosticSignInfo' })
vim.fn.sign_define('DiagnosticSignHint', { text = icons.diagnostics.Hint, texthl = 'DiagnosticSignHint' })
local neotree = require 'neo-tree'
neotree.setup {
  close_if_last_window = true,
  enable_git_status = true,
  enable_diagnostics = false,
  sources = { 'filesystem' },
  source_selector = {
    statusline = false,
  },
  open_files_do_not_replace_types = {
    'terminal',
    'trouble',
    'qf',
    'edgy',
    'telescopeprompt',
    'overseerlist',
    'OverseerList',
  },
  commands = {
    copy_selector = function(state)
      local node = state.tree:get_node()
      local filepath = node:get_id()
      local filename = node.name
      local modify = vim.fn.fnamemodify

      local vals = {
        ['BASENAME'] = modify(filename, ':r'),
        ['EXTENSION'] = modify(filename, ':e'),
        ['FILENAME'] = filename,
        ['PATH (CWD)'] = modify(filepath, ':.'),
        ['PATH (HOME)'] = modify(filepath, ':~'),
        ['PATH'] = filepath,
        ['URI'] = vim.uri_from_fname(filepath),
      }

      local options = vim.tbl_filter(function(val)
        return vals[val] ~= ''
      end, vim.tbl_keys(vals))
      if vim.tbl_isempty(options) then
        vim.notify('No values to copy', vim.log.levels.WARN)
        return
      end
      table.sort(options)
      vim.ui.select(options, {
        prompt = 'Choose to copy to clipboard:',
        format_item = function(item)
          return ('%s: %s'):format(item, vals[item])
        end,
      }, function(choice)
        local result = vals[choice]
        if result then
          vim.notify(('Copied: `%s`'):format(result))
          vim.fn.setreg('+', result)
        end
      end)
    end,
    telescope_find = function(state)
      local node = state.tree:get_node()
      local path = node:get_id()
      require('telescope.builtin').find_files(getTelescopeOpts(state, path))
    end,
    telescope_grep = function(state)
      local node = state.tree:get_node()
      local path = node:get_id()
      require('telescope.builtin').live_grep(getTelescopeOpts(state, path))
    end,
    telescope_find_current_buffer = function()
      require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_ivy {
        previewer = false,
        skip_empty_lines = true,
      })
    end,
    open_externally = function(state)
      local node = state.tree:get_node()
      vim.notify('Opening ' .. node.path)
      if node.type == 'directory' or node:has_children() then
        if not node:is_expanded() then -- if unexpanded, expand
          state.commands.toggle_node(state)
        else -- if expanded and has children, seleect the next child
          require('neo-tree.ui.renderer').focus_node(state, node:get_child_ids()[1])
        end
      elseif node.ext == 'jpg' or node.ext == 'png' or node.ext == 'pdf' or node.ext == 'svg' then
        if vim.fn.has 'mac' == 1 then
          vim.fn.system('open ' .. node.path)
        else
          vim.fn.jobstart("export DISPLAY=$(tmux show-env | sed -n 's/^DISPLAY=//p'); xdg-open " .. node.path .. ' || evince ' .. node.path)
        end
      elseif node.ext == 'root' then
        local tmux = require 'tmux-awesome-manager.src.term'
        tmux.run {
          cmd = "bash -i -c 'root -l " .. node.path .. "'",
          name = 'Open ROOT File',
          open_as = 'pane',
          orientation = 'horizontal',
          close_on_timer = 1,
          visit_first_call = true, -- will not focus the pane
          focus_when_call = true, -- Instead of focusing, will open a new pane in the same place as before
        }()
      else
        state.commands.open(state)
      end
    end,
    open_check_images = function(state)
      local node = state.tree:get_node()
      if node.ext == 'jpg' or node.ext == 'png' or node.ext == 'pdf' then
        local command = vim.fn.has 'mac' == 1 and 'open' or 'xdg-open'
        vim.notify('Open with ' .. command)
        vim.fn.jobstart(command .. ' ' .. node.path)
      else
        vim.cmd.edit(node.path)
      end
    end,
  },
  window = {
    position = 'left',
    mappings = {
      ['t'] = false,
      ['tf'] = 'telescope_find',
      ['tg'] = 'telescope_grep',
      ['O'] = 'open_externally',
      ['l'] = 'open',
      ['h'] = 'close_node',
      ['C'] = false,
      ['<c-s>'] = 'open_split',
      ['<c-v>'] = 'open_vsplit',
      ['D'] = 'delete',
      ['d'] = false,
      ['s'] = false,
      ['A'] = false,
      ['zh'] = 'toggle_hidden',
      ['z'] = false,
      ['Z'] = 'close_all_nodes',
      ['H'] = 'close_window',
      ['L'] = 'close_window',
      ['Y'] = 'copy_selector',
      ['<Space>'] = false,
      ['f'] = 'telescope_find_current_buffer',
    },
  },
  filesystem = {
    filtered_items = {
      always_show = {
        '.config',
        '.gitignore',
        '.rgignore',
        'config.json',
        'histo.root',
        'tuple.root',
        'yaml',
        '.schema.json',
      },
      hide_by_name = { 'GeneratorLog.xml', 'NewCatalog.xml' },
      hide_by_pattern = {
        '[0-9]*.py',
        '*.gif',
        '*.pdf',
        '*.png',
        '*.sim',
        '*.digi',
        '*.root',
        '*.mdf',
        '*.dst',
        'test_catalog-*.000000.xml',
      },
    },
  },
  event_handlers = {
    {
      event = 'file_opened',
      handler = function(_)
        require('neo-tree.command').execute { action = 'close' }
      end,
    },
  },
  default_component_configs = {
    git_status = {
      symbols = {
        -- Change type
        added = '✚',
        modified = '',
        deleted = '✖',
        renamed = 'R', -- this can only be used in the git_status source
        untracked = '?',
        ignored = '',
        unstaged = '󰄱',
        staged = '',
        conflict = '',
      },
    },
  },
}
