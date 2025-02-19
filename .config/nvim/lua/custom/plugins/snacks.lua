return {
  'folke/snacks.nvim',
  lazy = false,
  config = function()
    require 'custom.config.snacks'

    local map = function(key, func, desc)
      vim.keymap.set('n', key, func, { desc = desc })
    end

    -- all keymaps for snacks.picker
    map('<leader>ff', Snacks.picker.smart, 'Smart find file')
    map('<leader>fo', Snacks.picker.recent, 'Find recent file')
    map('<leader>fw', Snacks.picker.grep, 'Find content')
    map('<leader>fh', function()
      Snacks.picker.help { layout = 'dropdown' }
    end, 'Find in help')
    map('<leader>fl', Snacks.picker.picker_layouts, 'Find picker layout')
    map('<leader>fk', function()
      Snacks.picker.keymaps { layout = 'dropdown' }
    end, 'Find keymap')
    map('<leader><leader>', function()
      Snacks.picker.buffers { sort_lastused = true }
    end, 'Find buffers')
    map('<leader>fm', Snacks.picker.marks, 'Find mark')
    map('<leader>fn', function()
      Snacks.picker.notifications { layout = 'dropdown' }
    end, 'Find notification')
    map('grr', Snacks.picker.lsp_references, 'Find lsp references')
    map('<leader>fS', Snacks.picker.lsp_workspace_symbols, 'Find workspace symbol')
    map('<leader>fs', function()
      local bufnr = vim.api.nvim_get_current_buf()
      local clients = vim.lsp.get_clients { bufnr = bufnr }

      local function has_lsp_symbols()
        for _, client in ipairs(clients) do
          if client.server_capabilities.documentSymbolProvider then
            return true
          end
        end
        return false
      end

      if has_lsp_symbols() then
        Snacks.picker.lsp_symbols {
          layout = 'dropdown',
          tree = true,
          -- on_show = function()
          --   vim.cmd.stopinsert()
          -- end,
        }
      else
        Snacks.picker.treesitter()
      end
    end, 'Find symbol in current buffer')
    map('<leader>fi', Snacks.picker.icons, 'Find icon')
    map('<leader>fb', Snacks.picker.lines, 'Find lines in current buffer')
    map('<leader>fd', Snacks.picker.diagnostics_buffer, 'Find diagnostic in current buffer')
    map('<leader>fH', Snacks.picker.highlights, 'Find highlight')
    map('<leader>fc', function()
      Snacks.picker.files { cwd = vim.fn.stdpath 'config' }
    end, 'Find nvim config file')
    map('<leader>f/', Snacks.picker.search_history, 'Find search history')
    map('<leader>fj', Snacks.picker.jumps, 'Find jump')
    map('<leader>ft', function()
      if vim.bo.filetype == 'markdown' then
        Snacks.picker.grep_buffers {
          finder = 'grep',
          format = 'file',
          prompt = ' ',
          search = '^\\s*- \\[ \\]',
          regex = true,
          live = false,
          args = { '--no-ignore' },
          on_show = function()
            vim.cmd.stopinsert()
          end,
          buffers = false,
          supports_live = false,
          layout = 'ivy',
        }
      else
        Snacks.picker.todo_comments { keywords = { 'TODO', 'FIX', 'FIXME', 'HACK' }, layout = 'select' }
      end
    end, 'Find todo')

    -- other snacks features
    map('<leader>bc', Snacks.bufdelete.delete, 'Delete buffers')
    map('<leader>bC', Snacks.bufdelete.other, 'Delete other buffers')
    map('<leader>gg', function()
      Snacks.lazygit { cwd = Snacks.git.get_root() }
    end, 'Open lazygit')
    map('<leader>n', Snacks.notifier.show_history, 'Notification history')
    map('<leader>N', Snacks.notifier.hide, 'Notification history')
    map('<leader>gb', Snacks.git.blame_line, 'Git blame line')
  end,
}
