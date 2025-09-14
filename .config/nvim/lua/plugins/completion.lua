vim.pack.add({
    { src = "https://github.com/archie-judd/blink-cmp-words" },
    { src = "https://github.com/saghen/blink.cmp",           version = "v1.7.0" },
})

vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
    group = vim.api.nvim_create_augroup("SetupCompletion", { clear = true }),
    once = true,
    callback = function()
        require("blink.cmp").setup({
            completion = {
                documentation = {
                    auto_show = true,
                    window = {
                        border = "single",
                        scrollbar = false,
                    },
                },
                menu = {
                    border = "single",
                    auto_show = true,
                    auto_show_delay_ms = 0,
                    scrollbar = false,
                },
            },
            keymap = {
                ["<C-u>"] = { "scroll_documentation_up", "fallback" },
                ["<C-d>"] = { "scroll_documentation_down", "fallback" },
            },
            signature = {
                enabled = true,
            },
            cmdline = {
                completion = {
                    menu = {
                        auto_show = true,
                        -- border = "none",
                    },
                },
            },
            sources = {
                providers = {
                    snippets = {
                        score_offset = 1000,
                        should_show_items = function(ctx) -- avoid triggering snippets after . " ' chars.
                            return ctx.trigger.initial_kind ~= "trigger_character"
                        end,
                    },
                    -- Use the thesaurus source
                    thesaurus = {
                        name = "blink-cmp-words",
                        module = "blink-cmp-words.thesaurus",
                        -- All available options
                        opts = {
                            -- A score offset applied to returned items.
                            -- By default the highest score is 0 (item 1 has a score of -1, item 2 of -2 etc..).
                            score_offset = 0,

                            -- Default pointers define the lexical relations listed under each definition,
                            -- see Pointer Symbols below.
                            -- Default is as below ("antonyms", "similar to" and "also see").
                            definition_pointers = { "!", "&", "^" },

                            -- The pointers that are considered similar words when using the thesaurus,
                            -- see Pointer Symbols below.
                            -- Default is as below ("similar to", "also see" }
                            similarity_pointers = { "&", "^" },

                            -- The depth of similar words to recurse when collecting synonyms. 1 is similar words,
                            -- 2 is similar words of similar words, etc. Increasing this may slow results.
                            similarity_depth = 2,
                        },
                    },

                    -- Use the dictionary source
                    dictionary = {
                        name = "blink-cmp-words",
                        module = "blink-cmp-words.dictionary",
                        -- All available options
                        opts = {
                            -- The number of characters required to trigger completion.
                            -- Set this higher if completion is slow, 3 is default.
                            dictionary_search_threshold = 3,

                            -- See above
                            score_offset = 0,

                            -- See above
                            definition_pointers = { "!", "&", "^" },
                        },
                    },
                },
                -- Setup completion by filetype
                per_filetype = {
                    text = { "dictionary" },
                    markdown = { "thesaurus" },
                    typst = { "dictionary", "thesaurus" },
                    tex = { "dictionary", "thesaurus" },
                },
            },
        })
    end,
})
