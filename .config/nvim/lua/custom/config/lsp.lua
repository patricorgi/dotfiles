local icons = require 'custom.ui.icons'

vim.diagnostic.config {
  virtual_text = {
    spacing = 4,
    prefix = '󰧞',
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

--  This function gets run when an LSP attaches to a particular buffer.
--    That is to say, every time a new file is opened that is associated with
--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
--    function will be executed to configure the current buffer
vim.keymap.set('n', '<leader>lF', '<cmd>!lb-format %<cr>', { desc = 'Use lb-format' })
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    -- NOTE: Remember that Lua is a real programming language, and as such it is possible
    -- to define small helper and utility functions so you don't have to repeat yourself.
    --
    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end
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

    map('<leader>ld', function()
      vim.diagnostic.open_float { source = true }
    end, 'LSP Open Diagnostic')

    -- Jump to the definition of the word under your cursor.
    --  This is where a variable was first declared, or where a function is defined, etc.
    --  To jump back, press <C-t>.
    -- map('gd', require('telescope.builtin').lsp_definitions, 'Goto Definition')
    map('gd', function()
      local builtin = require 'telescope.builtin'
      local params = vim.lsp.util.make_position_params()

      -- Use the LSP's "textDocument/definition" request to check if there are results
      vim.lsp.buf_request(params.bufnr, 'textDocument/definition', params, function(_, result, _, _)
        if not result or vim.tbl_isempty(result) then
          -- Notify the user if no definitions are found
          vim.notify('No definition found', vim.log.levels.INFO)
        else
          -- Call Telescope's lsp_definitions if there are results
          builtin.lsp_definitions()
        end
      end)
    end, 'Goto Definition')
    map('gp', require('goto-preview').goto_preview_definition, 'Preview definition')

    -- Find references for the word under your cursor.
    map('gr', require('telescope.builtin').lsp_references, 'Goto References')

    -- Jump to the implementation of the word under your cursor.
    --  Useful when your language has ways of declaring types without an actual implementation.
    map('gI', require('telescope.builtin').lsp_implementations, 'Goto Implementation')

    -- Jump to the type of the word under your cursor.
    --  Useful when you're not sure what type a variable is and you want to see
    --  the definition of its *type*, not where it was *defined*.
    map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type Definition')

    -- -- Fuzzy find all the symbols in your current document.
    -- --  Symbols are things like variables, functions, types, etc.
    -- map('<leader>ls', require('telescope.builtin').lsp_document_symbols, 'Document Symbols')

    -- -- Fuzzy find all the symbols in your current workspace.
    -- --  Similar to document symbols, except searches over your entire project.
    -- map('<leader>lS', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace Symbols')

    -- Rename the variable under your cursor.
    --  Most Language Servers support renaming across files, etc.
    map('<leader>rn', vim.lsp.buf.rename, 'Lsp Rename')
    map('<leader>lr', vim.lsp.buf.rename, 'Lsp Rename')

    -- Execute a code action, usually your cursor needs to be on top of an error
    -- or a suggestion from your LSP for this to activate.
    map('<leader>la', vim.lsp.buf.code_action, 'Lsp Action')

    -- WARN: This is not Goto Definition, this is Goto Declaration.
    --  For example, in C this would take you to the header.
    map('gD', vim.lsp.buf.declaration, 'Goto Declaration')

    -- The following two autocommands are used to highlight references of the
    -- word under your cursor when your cursor rests there for a little while.
    --    See `:help CursorHold` for information about when this is executed
    --
    -- When you move your cursor, the highlights will be cleared (the second autocommand).
    local client = vim.lsp.get_client_by_id(event.data.client_id)
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

    -- The following code creates a keymap to toggle inlay hints in your
    -- code, if the language server you are using supports them
    --
    -- This may be unwanted, since they displace some of your code
    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
      vim.lsp.inlay_hint.enable()
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
      end, 'Toggle Inlay Hints')
    end
  end,
})
-- LSP servers and clients are able to communicate to each other what features they support.
--  By default, Neovim doesn't support everything that is in the LSP specification.
--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. Available keys are:
--  - cmd (table): Override the default command used to start the server
--  - filetypes (table): Override the default list of associated filetypes for the server
--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
--  - settings (table): Override the default settings passed when initializing the server.
--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
local mason_servers = {
  vtsls = {
    settings = {
      typescript = {
        inlayHints = {
          parameterNames = { enabled = 'literals' },
          parameterTypes = { enabled = true },
          variableTypes = { enabled = true },
          propertyDeclarationTypes = { enabled = true },
          functionLikeReturnTypes = { enabled = true },
          enumMemberValues = { enabled = true },
        },
      },
    },
  },
  clangd = { capabilities = { offsetEncoding = 'utf-8' }, cmd = { 'clangd' } },
  lua_ls = {
    settings = {
      Lua = {
        completion = {
          callSnippet = 'Replace',
        },
        -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
        -- diagnostics = { disable = { 'missing-fields' } },
      },
    },
  },
  ruff = {},
}

require('mason').setup()

-- You can add other tools here that you want Mason to install
-- for you, so that they are available from within Neovim.
-- local ensure_installed = vim.tbl_keys(servers or {})
-- vim.list_extend(ensure_installed, {
--   'stylua', -- Used to format Lua code
-- })
-- local ensure_installed = { 'yapf', 'shfmt', 'stylua', 'snakefmt', 'lua-language-server' }
-- require('mason-tool-installer').setup { ensure_installed = ensure_installed }

require('mason-lspconfig').setup {
  handlers = {
    function(server_name)
      local server = mason_servers[server_name] or {}
      -- This handles overriding only values explicitly passed
      -- by the server configuration above. Useful when disabling
      -- certain features of an LSP (for example, turning off formatting for tsserver)
      server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
      -- NOTE: Uncomment this line if you want to change hover highlight
      -- But this will change help page highlight too!
      -- vim.api.nvim_set_hl(0, 'NormalFloat', { bg = palette.crust, fg = palette.text })
      server.handler = {
        ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'single' }),
        ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'single' }),
      }
      require('lspconfig')[server_name].setup(server)
    end,
  },
}

local local_servers = {
  basedpyright = {
    cmd = { 'basedpyright-langserver', '--stdio' },
    settings = {
      basedpyright = {
        analysis = { typeCheckingMode = 'off' },
      },
    },
    root_dir = function(fname)
      local util = require 'lspconfig.util'
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
}

for server_name, server_opts in pairs(local_servers) do
  require('lspconfig')[server_name].setup(server_opts)
end

vim.cmd 'LspStart'
