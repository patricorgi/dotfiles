-- UI touches
local icons = require 'custom.ui.icons'
local util = require 'lspconfig.util'
vim.diagnostic.config {
  virtual_text = {
    spacing = 4,
    prefix = '',
  },
  float = {
    severity_sort = true,
    source = 'if_many',
    border = 'single',
  },
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

-- Main table for all LSP opts
local servers = {
  tinymist = {},
  lua_ls = {
    settings = {
      Lua = {
        completion = {
          callSnippet = 'Replace',
        },
      },
    },
  },
  clangd = { capabilities = { offsetEncoding = 'utf-8' }, cmd = { 'clangd' } },
  basedpyright = {
    settings = {
      basedpyright = {
        analysis = { typeCheckingMode = 'off' },
      },
    },
    root_dir = function(fname)
      local dir_name = util.root_pattern(unpack {
        'pyproject.toml',
        'setup.py',
        'setup.cfg',
        'requirements.txt',
        'Pipfile',
        'pyrightconfig.json',
        '.git',
      })(fname)
      if dir_name == nil then
        return vim.fs.dirname(fname)
      else
        return dir_name
      end
    end,
  },
  ruff = {},
  marksman = {},
  texlab = {
    settings = {
      texlab = {
        diagnostics = {
          ignoredPatterns = {
            'Overfull',
            'Underfull',
            'Package hyperref Warning',
            'Float too large for page',
            'contains only floats',
          },
        },
      },
    },
  },
}

-- Set up all server
local custom_handlers = {
  ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'single' }),
  ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'single' }),
}
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend('force', capabilities, require('blink.cmp').get_lsp_capabilities())
-- capabilities.textDocument.foldingRange = {
--   dynamicRegistration = false,
--   lineFoldingOnly = true,
-- }
local function setup_server(server_name, config)
  config.capabilities = vim.tbl_deep_extend('force', {}, capabilities, config.capabilities or {})
  config.handlers = vim.tbl_deep_extend('force', {}, custom_handlers, config.handlers or {})
  require('lspconfig')[server_name].setup(config)
end
for server_name, server_opt in pairs(servers) do
  setup_server(server_name, server_opt)
end

-- folding after capabilities is loaded
require 'custom.config.folding'

-- Define LSP-related keymaps
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('gd', function()
      vim.g.simple_indicator_on = true
      local params = vim.lsp.util.make_position_params()
      vim.lsp.buf_request(params.bufnr, 'textDocument/definition', params, function(_, result, _, _)
        if not result or vim.tbl_isempty(result) then
          vim.notify('No definition found', vim.log.levels.INFO)
        else
          -- vim.lsp.buf.definition()
          -- require('telescope.builtin').lsp_definitions()
          require('snacks').picker.lsp_definitions()
        end
        vim.g.simple_indicator_on = false
      end)
    end, 'Goto Definition')
    map('gD', vim.lsp.buf.declaration, 'Goto Declaration')
    map('gr', function()
      -- require('telescope.builtin').lsp_references()
      require('snacks').picker.lsp_references()
    end, 'Goto References')

    map('<leader>la', vim.lsp.buf.code_action, 'Lsp Action')
    map('<leader>rn', vim.lsp.buf.rename, 'Lsp Rename')

    -- Diagnostics
    map('<leader>ld', function()
      vim.diagnostic.open_float { source = true }
    end, 'LSP Open Diagnostic')
    map(
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
      'Toggle diagnostics display'
    )

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    -- Inlay hint
    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
      -- vim.lsp.inlay_hint.enable()
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
      end, 'Toggle Inlay Hints')
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
        end,
      })
    end
  end,
})
