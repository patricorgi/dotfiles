-- LSP, qi dong!
vim.lsp.enable 'lua_ls'
vim.lsp.enable 'clangd'
vim.lsp.enable 'pylsp'
vim.lsp.enable 'ruff'
vim.lsp.enable 'marksman'
vim.lsp.enable 'tinymist'
vim.lsp.enable 'texlab'

-- Define LSP-related keymaps
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    vim.keymap.set('n', 'gd', function()
      local params = vim.lsp.util.make_position_params(0, 'utf-8')
      vim.lsp.buf_request(0, 'textDocument/definition', params, function(_, result, _, _)
        if not result or vim.tbl_isempty(result) then
          vim.notify('No definition found', vim.log.levels.INFO)
        else
          require('snacks').picker.lsp_definitions()
        end
      end)
    end, { buffer = event.buf, desc = 'LSP: Goto Definition' })

    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = event.buf, desc = 'LSP: Goto Declaration' })
    vim.keymap.set('n', 'gr', function()
      -- require('telescope.builtin').lsp_references()
      require('snacks').picker.lsp_references()
    end, { buffer = event.buf, desc = 'LSP: Goto References' })

    vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action, { buffer = event.buf, desc = 'Lsp Action' })
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = event.buf, desc = 'LSP: Rename' })

    -- Diagnostics
    vim.keymap.set('n', '<leader>ld', function()
      vim.diagnostic.open_float { source = true }
    end, { buffer = event.buf, desc = 'LSP: Show Diagnostic' })
    vim.keymap.set(
      'n',
      '<leader>td',
      (function()
        local diag_status = 1 -- 1 is show; 0 is hide
        return function()
          if diag_status == 1 then
            diag_status = 0
            vim.diagnostic.config { underline = false, virtual_text = false, signs = false, update_in_insert = false }
          else
            diag_status = 1
            vim.diagnostic.config { underline = true, virtual_text = true, signs = true, update_in_insert = true }
          end
        end
      end)(),
      { buffer = event.buf, desc = 'LSP: Toggle diagnostics display' }
    )

    -- folding
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.supports_method 'textDocument/foldingRange' then
      local win = vim.api.nvim_get_current_win()
      vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
    end

    -- Inlay hint
    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
      -- vim.lsp.inlay_hint.enable()
      vim.keymap.set('n', '<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
      end, { buffer = event.buf, desc = 'LSP: Toggle Inlay Hints' })
    end

    -- Highlight words under cursor
    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) and vim.bo.filetype ~= 'bigfile' then
      local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
          -- vim.cmd 'setl foldexpr <'
        end,
      })
    end
  end,
})

-- diagnostic UI touches
local icons = require 'custom.ui.icons'
vim.diagnostic.config {
  virtual_lines = { current_line = true },
  -- virtual_text = {
  --   spacing = 4,
  --   prefix = '',
  -- },
  float = { severity_sort = true },
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
      [vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
      [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
      [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
    },
  },
}
