vim.pack.add({
    { src = "https://github.com/mason-org/mason.nvim" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
})

require("mason").setup()
vim.lsp.enable("clangd")
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("SetupLSP", {}),
    callback = function(event)
        local client = assert(vim.lsp.get_client_by_id(event.data.client_id))

        -- [inlay hint]
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            vim.keymap.set('n', '<leader>th', function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, { buffer = event.buf, desc = 'LSP: Toggle Inlay Hints' })
        end

        -- [folding]
        if client and client:supports_method 'textDocument/foldingRange' then
            local win = vim.api.nvim_get_current_win()
            vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
        end

        -- [keymaps]
        vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format)
        vim.keymap.set("n", "gd", function()
            local params = vim.lsp.util.make_position_params(0, "utf-8")
            vim.lsp.buf_request(0, "textDocument/definition", params, function(_, result, _, _)
                if not result or vim.tbl_isempty(result) then
                    vim.notify("No definition found", vim.log.levels.INFO)
                else
                    require("snacks").picker.lsp_definitions()
                end
            end)
        end, { buffer = event.buf, desc = "LSP: Goto Definition" })
        vim.keymap.set("n", "gD", function()
            local win = vim.api.nvim_get_current_win()
            local width = vim.api.nvim_win_get_width(win)
            local height = vim.api.nvim_win_get_height(win)

            -- Mimic tmux formula: 8 * width - 20 * height
            local value = 8 * width - 20 * height
            if value < 0 then
                vim.cmd("split")  -- vertical space is more: horizontal split
            else
                vim.cmd("vsplit") -- horizontal space is more: vertical split
            end

            vim.lsp.buf.definition()
        end, { buffer = event.buf, desc = "LSP: Goto Definition (split)" })

        local function jump_to_current_function_start()
            local params = { textDocument = vim.lsp.util.make_text_document_params() }
            local responses = vim.lsp.buf_request_sync(0, "textDocument/documentSymbol", params, 1000)
            if not responses then return end

            local pos = vim.api.nvim_win_get_cursor(0)
            local line = pos[1] - 1

            local function find_symbol(symbols)
                for _, s in ipairs(symbols) do
                    local range = s.range or (s.location and s.location.range)
                    if range and line >= range.start.line and line <= range["end"].line then
                        if s.children then
                            local child = find_symbol(s.children)
                            if child then return child end
                        end
                        return s
                    end
                end
            end

            for _, resp in pairs(responses) do
                local sym = find_symbol(resp.result or {})
                if sym and sym.range then
                    vim.api.nvim_win_set_cursor(0, { sym.range.start.line + 1, 0 })
                    return
                end
            end
        end
        vim.keymap.set("n", "[f", jump_to_current_function_start, { desc = "Jump to start of current function" })
        local function jump_to_current_function_end()
            local params = { textDocument = vim.lsp.util.make_text_document_params() }
            local responses = vim.lsp.buf_request_sync(0, "textDocument/documentSymbol", params, 1000)
            if not responses then return end

            local pos = vim.api.nvim_win_get_cursor(0)
            local line = pos[1] - 1

            local function find_symbol(symbols)
                for _, s in ipairs(symbols) do
                    local range = s.range or (s.location and s.location.range)
                    if range and line >= range.start.line and line <= range["end"].line then
                        if s.children then
                            local child = find_symbol(s.children)
                            if child then return child end
                        end
                        return s
                    end
                end
            end

            for _, resp in pairs(responses) do
                local sym = find_symbol(resp.result or {})
                if sym and sym.range then
                    -- jump to end of the symbol
                    vim.api.nvim_win_set_cursor(0, { sym.range["end"].line + 1, 0 })
                    return
                end
            end
        end
        vim.keymap.set("n", "]f", jump_to_current_function_end, { desc = "Jump to end of current function" })
    end,
})

-- vim.cmd([[set completeopt+=menuone,noselect,popup]])
