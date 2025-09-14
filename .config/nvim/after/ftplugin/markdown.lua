if vim.b.did_my_ftplugin then
  return
end
vim.b.did_my_ftplugin = true
vim.lsp.enable("marksman")
require("render-markdown").setup({
	callout = {
		abstract = {
			raw = "[!ABSTRACT]",
			rendered = "󰯂 Abstract",
			highlight = "RenderMarkdownInfo",
			category = "obsidian",
		},
		summary = {
			raw = "[!SUMMARY]",
			rendered = "󰯂 Summary",
			highlight = "RenderMarkdownInfo",
			category = "obsidian",
		},
		tldr = { raw = "[!TLDR]", rendered = "󰦩 Tldr", highlight = "RenderMarkdownInfo", category = "obsidian" },
		failure = {
			raw = "[!FAILURE]",
			rendered = " Failure",
			highlight = "RenderMarkdownError",
			category = "obsidian",
		},
		fail = { raw = "[!FAIL]", rendered = " Fail", highlight = "RenderMarkdownError", category = "obsidian" },
		missing = {
			raw = "[!MISSING]",
			rendered = " Missing",
			highlight = "RenderMarkdownError",
			category = "obsidian",
		},
		attention = {
			raw = "[!ATTENTION]",
			rendered = " Attention",
			highlight = "RenderMarkdownWarn",
			category = "obsidian",
		},
		warning = {
			raw = "[!WARNING]",
			rendered = " Warning",
			highlight = "RenderMarkdownWarn",
			category = "github",
		},
		danger = {
			raw = "[!DANGER]",
			rendered = " Danger",
			highlight = "RenderMarkdownError",
			category = "obsidian",
		},
		error = { raw = "[!ERROR]", rendered = " Error", highlight = "RenderMarkdownError", category = "obsidian" },
		bug = { raw = "[!BUG]", rendered = " Bug", highlight = "RenderMarkdownError", category = "obsidian" },
		quote = { raw = "[!QUOTE]", rendered = " Quote", highlight = "RenderMarkdownQuote", category = "obsidian" },
		cite = { raw = "[!CITE]", rendered = " Cite", highlight = "RenderMarkdownQuote", category = "obsidian" },
		todo = { raw = "[!TODO]", rendered = " Todo", highlight = "RenderMarkdownInfo", category = "obsidian" },
		wip = { raw = "[!WIP]", rendered = "󰦖 WIP", highlight = "RenderMarkdownHint", category = "obsidian" },
		done = { raw = "[!DONE]", rendered = " Done", highlight = "RenderMarkdownSuccess", category = "obsidian" },
	},
	sign = { enabled = false },
	code = {
		-- general
		width = "block",
		min_width = 80,
		-- borders
		border = "thin",
		left_pad = 1,
		right_pad = 1,
		-- language info
		position = "right",
		language_icon = true,
		language_name = true,
		-- avoid making headings ugly
		highlight_inline = "RenderMarkdownCodeInfo",
	},
	heading = {
		icons = { " 󰼏 ", " 󰎨 ", " 󰼑 ", " 󰎲 ", " 󰼓 ", " 󰎴 " },
		border = true,
		render_modes = true, -- keep rendering while inserting
	},
	checkbox = {
		unchecked = {
			icon = "󰄱",
			highlight = "RenderMarkdownCodeFallback",
			scope_highlight = "RenderMarkdownCodeFallback",
		},
		checked = {
			icon = "󰄵",
			highlight = "RenderMarkdownUnchecked",
			scope_highlight = "RenderMarkdownUnchecked",
		},
		custom = {
			question = {
				raw = "[?]",
				rendered = "",
				highlight = "RenderMarkdownError",
				scope_highlight = "RenderMarkdownError",
			},
			todo = {
				raw = "[>]",
				rendered = "󰦖",
				highlight = "RenderMarkdownInfo",
				scope_highlight = "RenderMarkdownInfo",
			},
			canceled = {
				raw = "[-]",
				rendered = "",
				highlight = "RenderMarkdownCodeFallback",
				scope_highlight = "@text.strike",
			},
			important = {
				raw = "[!]",
				rendered = "",
				highlight = "RenderMarkdownWarn",
				scope_highlight = "RenderMarkdownWarn",
			},
			favorite = {
				raw = "[~]",
				rendered = "",
				highlight = "RenderMarkdownMath",
				scope_highlight = "RenderMarkdownMath",
			},
		},
	},
	pipe_table = {
		alignment_indicator = "─",
		border = { "╭", "┬", "╮", "├", "┼", "┤", "╰", "┴", "╯", "│", "─" },
	},
	link = {
		wiki = { icon = " ", highlight = "RenderMarkdownWikiLink", scope_highlight = "RenderMarkdownWikiLink" },
		image = " ",
		custom = {
			github = { pattern = "github", icon = " " },
			gitlab = { pattern = "gitlab", icon = "󰮠 " },
			youtube = { pattern = "youtube", icon = " " },
			cern = { pattern = "cern.ch", icon = " " },
		},
		hyperlink = " ",
	},
	anti_conceal = {
		disabled_modes = { "n" },
		ignore = {
			bullet = true, -- render bullet in insert mode
			head_border = true,
			head_background = true,
		},
	},
	-- https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/509
	win_options = { concealcursor = { rendered = "nvc" } },
	completions = {
		blink = { enabled = true },
		lsp = { enabled = true },
	},
})

vim.lsp.enable 'marksman'
vim.o.wrap = false
vim.opt.conceallevel = 2
vim.keymap.set('n', 'gx', function()
  local line = vim.fn.getline '.'
  local cursor_col = vim.fn.col '.'
  local pos = 1
  while pos <= #line do
    local open_bracket = line:find('%[', pos)
    if not open_bracket then
      break
    end
    local close_bracket = line:find('%]', open_bracket + 1)
    if not close_bracket then
      break
    end
    local open_paren = line:find('%(', close_bracket + 1)
    if not open_paren then
      break
    end
    local close_paren = line:find('%)', open_paren + 1)
    if not close_paren then
      break
    end
    if (cursor_col >= open_bracket and cursor_col <= close_bracket) or (cursor_col >= open_paren and cursor_col <= close_paren) then
      local url = line:sub(open_paren + 1, close_paren - 1)
      vim.ui.open(url)
      return
    end
    pos = close_paren + 1
  end
  vim.cmd 'normal! gx'
end, { buffer = true, desc = 'URL opener for markdown' })

local function pad_to_eol(str)
  local win_width = vim.api.nvim_win_get_width(0) -- current window width
  local str_width = vim.fn.strdisplaywidth(str) -- visual width of the string
  local spaces_needed = win_width - str_width

  if spaces_needed > 0 then
    return str .. string.rep(' ', spaces_needed)
  else
    return str
  end
end

local function fold_virt_text(result, start_text, lnum)
  -- extmarks highlight
  local ns_id = vim.api.nvim_get_namespaces()['render-markdown.nvim']
  local extmarks = vim.api.nvim_buf_get_extmarks(0, ns_id, { lnum, 0 }, { lnum, 0 }, { details = true })
  local details = extmarks[#extmarks][4] or {}
  local ext_hl_str
  if details then
    ext_hl_str = details.hl_group
  end

  -- ts highlight
  local captured_highlights = vim.treesitter.get_captures_at_pos(0, lnum, 0)
  local ts_hl_str = '@' .. captured_highlights[#captured_highlights].capture .. '.markdown'
  ts_hl_str = vim.api.nvim_get_hl(0, { name = ts_hl_str, link = true }).link

  -- merge highlight
  local ext_hl = vim.api.nvim_get_hl(0, { name = ext_hl_str })
  local ts_hl = vim.api.nvim_get_hl(0, { name = ts_hl_str })

  -- Create a combined group
  vim.api.nvim_set_hl(0, 'MyMergedHL', { fg = ts_hl.fg, bg = ext_hl.bg })
  vim.api.nvim_set_hl(0, 'MyInvertMergeHL', { fg = ext_hl.bg, bg = nil })
  table.insert(result, { pad_to_eol(start_text), 'MyMergedHL' })
end

function _G.markdown_foldtext()
  local start_text = vim.fn.getline(vim.v.foldstart):gsub('\t', string.rep(' ', vim.o.tabstop))
  local result = {}
  fold_virt_text(result, start_text, vim.v.foldstart - 1)
  return result
end
vim.opt.foldtext = 'v:lua.markdown_foldtext()'
vim.o.fillchars = [[eob: ,fold: ,foldopen: ,foldsep: ,foldclose: ]]

-- Function to fold all headings of a specific level
local function fold_headings_of_level(level)
  -- Move to the top of the file without adding to jumplist
  vim.cmd 'keepjumps normal! gg'
  -- Get the total number of lines
  local total_lines = vim.fn.line '$'
  for line = 1, total_lines do
    -- Get the content of the current line
    local line_content = vim.fn.getline(line)
    -- "^" -> Ensures the match is at the start of the line
    -- string.rep("#", level) -> Creates a string with 'level' number of "#" characters
    -- "%s" -> Matches any whitespace character after the "#" characters
    -- So this will match `## `, `### `, `#### ` for example, which are markdown headings
    if line_content:match('^' .. string.rep('#', level) .. '%s') then
      -- Move the cursor to the current line without adding to jumplist
      vim.cmd(string.format('keepjumps call cursor(%d, 1)', line))
      -- Check if the current line has a fold level > 0
      local current_foldlevel = vim.fn.foldlevel(line)
      if current_foldlevel > 0 then
        -- Fold the heading if it matches the level
        if vim.fn.foldclosed(line) == -1 then
          vim.cmd 'normal! za'
        end
        -- else
        --   vim.notify("No fold at line " .. line, vim.log.levels.WARN)
      end
    end
  end
end

local function fold_markdown_headings(levels)
  -- I save the view to know where to jump back after folding
  local saved_view = vim.fn.winsaveview()
  for _, level in ipairs(levels) do
    fold_headings_of_level(level)
  end
  vim.cmd 'nohlsearch'
  -- Restore the view to jump to where I was
  vim.fn.winrestview(saved_view)
end

vim.keymap.set('n', 'zM', function()
  -- "Update" saves only if the buffer has been modified since the last save
  vim.cmd 'silent update'
  -- vim.keymap.set("n", "<leader>mfk", function()
  -- Reloads the file to refresh folds, otherwise you have to re-open neovim
  vim.cmd 'edit!'
  -- Unfold everything first or I had issues
  vim.cmd 'normal! zR'
  fold_markdown_headings { 6, 5, 4, 3, 2 }
  vim.cmd 'normal! zz' -- center the cursor line on screen
end, { desc = '[P]Fold all headings level 2 or above' })
