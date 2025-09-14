vim.keymap.set("n", "<leader>o", ":update<CR> :source<CR>")
vim.keymap.set("n", "<leader>w", ":write<CR>")
vim.keymap.set("n", "<leader>R", ":restart<CR>")
vim.keymap.set(
	{ "n", "x", "v" },
	"j",
	"v:count == 0 ? 'gj' : 'j'",
	{ expr = true, silent = true, desc = "Move cursor down" }
)
vim.keymap.set(
	{ "n", "x", "v" },
	"k",
	"v:count == 0 ? 'gk' : 'k'",
	{ expr = true, silent = true, desc = "Move cursor up" }
)
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "\\", "<CMD>:sp<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "|", "<CMD>:vsp<CR>", { desc = "Split window vertically" })
-- lua dev
vim.keymap.set("n", "<space>X", "<cmd>source %<cr>", { desc = "Run this lua file" })
vim.keymap.set("n", "<space>x", ":.lua<cr>", { desc = "Run this line" })
vim.keymap.set("v", "<space>x", ":lua<cr>", { desc = "Run selection" })
-- tab
vim.keymap.set("n", "L", "gt", { noremap = true, desc = "Go to next tab" })
vim.keymap.set("n", "H", "gT", { noremap = true, desc = "Go to prev tab" })
vim.keymap.set("n", "<C-w><C-t>", function()
	vim.cmd("tab split")
end, { desc = "Open current buffer in new tab" })

-- set text to terminal buffer
local function send_to_terminal(term_name, init_cmd)
	local mode = vim.fn.mode()
	local text

	if mode == "v" or mode == "V" or mode == "\22" then
		-- Yank visual selection without clobbering registers
		vim.cmd('normal! "vy')
		text = vim.fn.getreg("v") -- we used the v register
	else
		-- Get entire buffer
		text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
	end

	-- update DISPLAY
	local handle = io.popen(
		[[bash -c '[ -n "$TMUX" ] && export DISPLAY=$(tmux show-env | sed -n "s/^DISPLAY=//p"); echo -n $DISPLAY']]
	)
	local display_value
	if handle then
		display_value = handle:read("*a")
		handle:close()
	end

	local target_buf = nil
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if
			vim.api.nvim_buf_is_loaded(buf)
			and vim.bo[buf].buftype == "terminal"
			and vim.api.nvim_buf_get_name(buf):match(term_name .. "$")
		then
			target_buf = buf
			break
		end
	end

	-- If no ROOT terminal, create one
	if not target_buf then
		if init_cmd then
			vim.cmd(
				"vsplit | term bash -i -l -c '[ -n \"$TMUX\" ] && export DISPLAY=$(tmux show-env | sed -n 's/^DISPLAY=//p'); "
					.. init_cmd
					.. "'"
			)
		else
			vim.cmd(
				"vsplit | term bash -i -l -c '[ -n \"$TMUX\" ] && export DISPLAY=$(tmux show-env | sed -n 's/^DISPLAY=//p');'"
			)
		end
		target_buf = vim.api.nvim_get_current_buf()
		vim.api.nvim_buf_set_name(target_buf, term_name)
		-- vim.b.term_name = 'ROOT'
	end

	-- Send to ROOT terminal
	local chan_id = vim.b[target_buf].terminal_job_id
	if term_name == "term:ROOT" then
		vim.fn.chansend(chan_id, 'gSystem->Setenv("DISPLAY", "' .. display_value .. '");' .. "\n")
	end
	vim.fn.chansend(chan_id, text)
end

vim.keymap.set("n", "<leader>sR", function()
	send_to_terminal("term:ROOT", "r")
end, { desc = "Send to term:ROOT" })
vim.keymap.set("v", "<leader>sr", function()
	send_to_terminal("term:ROOT", "r")
end, { desc = "Send to term:ROOT" })
vim.keymap.set("v", "<leader>sp", function()
	send_to_terminal("term:python", "python3")
end, { desc = "Send to term:python" })
vim.keymap.set("n", "<leader>tp", function()
	local terminals = {
		{
			name = "ROOT",
			cmd = "bash -i -l -c '[ -n \"$TMUX\" ] && export DISPLAY=$(tmux show-env | sed -n 's/^DISPLAY=//p'); r'",
		},
		{ name = "Python", cmd = "python3" },
		{ name = "Bash", cmd = "" },
		{ name = "My Script", cmd = "bash -i -l -c '~/myscript.sh'" },
	}
	vim.ui.select(terminals, {
		prompt = "Pick terminal:",
		format_item = function(item)
			return item.name
		end,
	}, function(choice)
		if choice then
			vim.cmd("split | terminal " .. choice.cmd)
			-- name the buffer after its terminal preset
			local buf = vim.api.nvim_get_current_buf()
			vim.api.nvim_buf_set_name(buf, "term:" .. choice.name)
			vim.b.term_name = choice.name
		end
	end)
end, { desc = "Pick predefined terminal" })

-- [plugins] loaded only when pressing a key
vim.keymap.set("n", "<leader>rl", function()
	vim.keymap.del("n", "<leader>rl")
	require("plugins.overseer")
	vim.cmd("OverseerRun")
end)

vim.keymap.set("n", "<leader>ds", function()
	vim.keymap.del("n", "<leader>ds")
	require("plugins.debugging")
end)

vim.keymap.set("n", "<leader>Cp", function()
	local commands = {
		{
			name = "Copilot: Actions",
			action = "<leader>ca",
		},
		{
			name = "Dim: Toggle",
			action = function()
				local snacks_dim = require("snacks").dim
				if snacks_dim.enabled then
					snacks_dim.disable()
				else
					snacks_dim.enable()
				end
			end,
		},
		{
			name = "Tab: Close",
			action = ":tabclose",
		},
		{
			name = "Tab: New",
			action = ":tabnew",
		},
		{
			name = "Todo Comments: Quickfix List",
			action = ":TodoQuickFix",
		},
		{
			name = "Todo Comments: Location List",
			action = ":TodoLocList",
		},
	}
	local items = {}

	for idx, command in ipairs(commands) do
		local item = {
			idx = idx,
			name = command.name,
			text = command.name,
			action = command.action,
		}
		table.insert(items, item)
	end

	Snacks.picker({
		title = "Command Palette",
		layout = {
			preset = "default",
			preview = false,
		},
		items = items,
		format = function(item, _)
			return {
				{ item.text, item.text_hl },
			}
		end,
		confirm = function(picker, item)
			if type(item.action) == "string" then
				if item.action:find("^:") then
					picker:close()
					return picker:norm(function()
						picker:close()
						vim.cmd(item.action:sub(2))
					end)
				else
					return picker:norm(function()
						picker:close()
						local keys = vim.api.nvim_replace_termcodes(item.action, true, true, true)
						vim.api.nvim_input(keys)
					end)
				end
			end

			return picker:norm(function()
				picker:close()
				item.action()
			end)
		end,
	})
end, { desc = "Open custom picker" })
