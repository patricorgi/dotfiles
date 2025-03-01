---@diagnostic disable: undefined-global, assign-type-mismatch, missing-fields
return {
  'folke/snacks.nvim',
  lazy = false,
  -- dependencies = { 'stevearc/aerial.nvim', opts = {} },
  config = function()
    require 'custom.config.snacks'
  end,
  keys = {
    {
      '<leader>gg',
      function()
        Snacks.lazygit { cwd = Snacks.git.get_root() }
      end,
      desc = 'Lazygit current buffer',
    },
    {
      '<leader>bc',
      function()
        Snacks.bufdelete()
      end,
      desc = 'Delete Buffer',
    },
    {
      '<leader>bC',
      function()
        Snacks.bufdelete.other()
      end,
      desc = 'Delete Other Buffers',
    },
    {
      '<leader>n',
      function()
        Snacks.notifier.show_history()
      end,
      desc = 'Notification History',
    },
    {
      '<leader>gb',
      function()
        Snacks.git.blame_line()
      end,
      desc = 'Git Blame Line',
    },
    {
      '<leader>ff',
      function()
        Snacks.picker.smart()
      end,
      desc = 'Smart Find Files',
    },
    {
      '<leader>fF',
      function()
        Snacks.picker.smart {
          ignored = true,
        }
      end,
      desc = 'Smart Find Files',
    },
    {
      '<leader>fo',
      function()
        Snacks.picker.recent()
      end,
      desc = 'Smart Find Files',
    },
    {
      '<leader><leader>',
      function()
        Snacks.picker.buffers {
          sort_lastused = true,
        }
      end,
      desc = 'Buffers',
    },
    {
      '<leader>fh',
      function()
        Snacks.picker.help {
          layout = 'dropdown',
        }
      end,
      desc = 'Help Pages',
    },
    {
      '<leader>fL',
      function()
        Snacks.picker.picker_layouts()
      end,
      desc = 'Picker layout',
    },
    {
      '<leader>fk',
      function()
        Snacks.picker.keymaps {
          layout = 'dropdown',
        }
      end,
      desc = 'Keymaps',
    },
    {
      '<leader>fm',
      function()
        Snacks.picker.marks()
      end,
      desc = 'Marks',
    },
    {
      '<leader>fn',
      function()
        Snacks.picker.notifications()
      end,
      desc = 'Notification History',
    },
    {
      '<leader>fc',
      function()
        Snacks.picker.files { cwd = vim.fn.stdpath 'config' }
      end,
      desc = 'Find Config File',
    },
    {
      '<leader>fw',
      function()
        Snacks.picker.grep()
      end,
      desc = 'Grep',
    },
    {
      '<leader>fW',
      function()
        Snacks.picker.grep_word()
      end,
      desc = 'Grep Word Under Cursor',
      mode = { 'n', 'x' },
    },
    {
      '<leader>ls',
      function()
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

        local picker_opts = {
          layout = 'left',
          tree = true,
          on_show = function()
            vim.cmd.stopinsert()
          end,
        }
        if has_lsp_symbols() then
          Snacks.picker.lsp_symbols(picker_opts)
        else
          Snacks.picker.treesitter()
          -- require('aerial').snacks_picker(picker_opts)
        end
      end,
      desc = 'LSP Symbols',
    },
    {
      '<leader>fs',
      function()
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

        local picker_opts = {
          layout = 'left',
          tree = true,
        }
        if has_lsp_symbols() then
          Snacks.picker.lsp_symbols(picker_opts)
        else
          Snacks.picker.treesitter()
          -- require('aerial').snacks_picker(picker_opts)
        end
      end,
      desc = 'LSP Symbols',
    },
    {
      '<leader>fS',
      function()
        Snacks.picker.lsp_workspace_symbols {
          layout = 'dropdown',
        }
      end,
      desc = 'LSP Workspace Symbols',
    },
    {
      '<leader>fi',
      function()
        Snacks.picker.icons()
      end,
      desc = 'Icons',
    },
    {
      '<leader>fd',
      function()
        Snacks.picker.diagnostics()
      end,
      desc = 'Diagnostics',
    },
    {
      '<leader>f/',
      function()
        Snacks.picker.lines()
      end,
      desc = 'Buffer Lines',
    },
    {
      '<leader>fT',
      function()
        Snacks.picker.todo_comments { keywords = { 'TODO', 'FIX', 'FIXME', 'HACK' }, layout = 'select' }
      end,
      desc = 'Todo/Fix/Fixme',
    },
    -- {
    --   '<leader>fT',
    --   function()
    --     Snacks.picker.grep {
    --       prompt = ' ',
    --       -- pass your desired search as a static pattern
    --       search = '^\\s*- \\[ \\]',
    --       -- we enable regex so the pattern is interpreted as a regex
    --       regex = true,
    --       -- no “live grep” needed here since we have a fixed pattern
    --       live = false,
    --       -- restrict search to the current working directory
    --       dirs = { vim.fn.getcwd() },
    --       -- include files ignored by .gitignore
    --       args = { '--no-ignore' },
    --       -- Start in normal mode
    --       on_show = function()
    --         vim.cmd.stopinsert()
    --       end,
    --       finder = 'grep',
    --       format = 'file',
    --       show_empty = true,
    --       supports_live = false,
    --       layout = 'ivy',
    --     }
    --   end,
    --   desc = '[P]Search for incomplete tasks',
    -- },
    {
      '<leader>ft',
      function()
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
      end,
      desc = 'Search for incomplete tasks',
    },
    {
      '<leader>fH',
      function()
        Snacks.picker.highlights()
      end,
      desc = 'Buffer Lines',
    },
    {
      '<leader>fb',
      function()
        Snacks.picker.git_branches()
      end,
      desc = 'Git branches',
    },
    {
      '<leader>fp',
      function()
        Snacks.picker.projects()
      end,
      desc = 'Projects',
    },
  },
}
