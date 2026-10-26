vim.pack.add({
	{ src = "https://github.com/nickjvandyke/opencode.nvim" },
})

local opencode_window = "opencode"
local opencode_cmd = [[bash -lc 'source "$HOME/dotfiles/bash/functions" && ops']]
local tmux_window_exists

local function load_opencode_auth()
	if vim.env.OPENCODE_SERVER_PASSWORD and vim.env.OPENCODE_SERVER_PASSWORD ~= "" then
		return
	end

	local password_file = vim.env.OPENCODE_SERVER_ENV_FILE
		or vim.fn.expand("~/.config/opencode/server.env")
	local ok, lines = pcall(vim.fn.readfile, password_file)
	if not ok then
		return
	end
	for _, line in ipairs(lines) do
		local password = line:match("^OPENCODE_SERVER_PASSWORD=(.*)$")
		if password and password ~= "" then
			vim.env.OPENCODE_SERVER_PASSWORD = password
			return
		end
	end
end

load_opencode_auth()

local function service_registration()
	local state_home = vim.env.XDG_STATE_HOME
	local state_dir = state_home and state_home ~= "" and vim.fs.joinpath(state_home, "opencode")
		or vim.fs.joinpath(vim.uv.os_homedir(), ".local", "state", "opencode")
	local ok, lines = pcall(vim.fn.readfile, vim.fs.joinpath(state_dir, "service.json"))
	if not ok then
		return nil
	end

	local decoded_ok, registration = pcall(vim.json.decode, table.concat(lines, "\n"))
	if decoded_ok and type(registration) == "table" and type(registration.url) == "string" then
		return registration
	end
end

local function discover_opencode_servers(callback)
	local candidates = {}
	local seen = {}
	local function add(url, label, password)
		url = url:gsub("/$", "")
		if not seen[url] then
			seen[url] = true
			table.insert(candidates, { url = url, label = label, password = password })
		end
	end

	local port = tonumber(vim.env.OPENCODE_PORT) or 4096
	add("http://127.0.0.1:" .. port, "Local server (port " .. port .. ")", vim.env.OPENCODE_SERVER_PASSWORD)
	local registration = service_registration()
	if registration then
		add(registration.url, "OpenCode v2 service (" .. registration.url .. ")", registration.password)
	end

	local available = {}
	local remaining = #candidates
	if remaining == 0 then
		callback({})
		return
	end

	local function complete(candidate, code, response)
		local decoded_ok, info = pcall(vim.json.decode, response or "")
		if code == 0 and decoded_ok and type(info) == "table" then
			table.insert(available, candidate)
		end
		remaining = remaining - 1
		if remaining == 0 then
			vim.schedule(function()
				callback(available)
			end)
		end
	end

	for _, candidate in ipairs(candidates) do
		local command = { "curl", "--silent", "--show-error", "--fail", "--max-time", "1" }
		if candidate.password and candidate.password ~= "" then
			table.insert(command, "--user")
			table.insert(command, (vim.env.OPENCODE_SERVER_USERNAME or "opencode") .. ":" .. candidate.password)
		end
		table.insert(command, candidate.url .. "/api/info")

		local stdout = {}
		local job_id = vim.fn.jobstart(command, {
			on_stdout = function(_, data)
				for _, line in ipairs(data or {}) do
					if line ~= "" then
						table.insert(stdout, line)
					end
				end
			end,
			on_exit = function(_, code)
				complete(candidate, code, table.concat(stdout, "\n"))
			end,
		})
		if job_id <= 0 then
			complete(candidate, 1, "")
		end
	end
end

local function select_opencode_server(callback)
	discover_opencode_servers(function(servers)
		if #servers == 0 then
			callback(nil)
		elseif #servers == 1 then
			callback(servers[1])
		else
			vim.ui.select(servers, {
				prompt = "Select OpenCode server:",
				format_item = function(server)
					return server.label
				end,
			}, callback)
		end
	end)
end

local function start_opencode_tmux()
	if not tmux_window_exists() then
		vim.fn.system({ "tmux", "new-window", "-n", opencode_window, opencode_cmd })
	end
end

local function select_or_start_opencode_server(callback, attempts)
	select_opencode_server(function(server)
		if server then
			callback(server)
			return
		end

		if attempts == 0 then
			callback(nil)
			return
		end

		start_opencode_tmux()
		vim.defer_fn(function()
			select_or_start_opencode_server(callback, attempts - 1)
		end, 1000)
	end)
end

tmux_window_exists = function()
	local windows = vim.fn.systemlist({ "tmux", "list-windows", "-F", "#W" })
	return vim.tbl_contains(windows, opencode_window)
end

vim.g.opencode_opts = {
	server = {
		-- opencode.nvim's main branch speaks the OpenCode v2 API.  Prefer a
		-- directly started server on OPENCODE_PORT/4096, but also discover the
		-- v2 background service.  When both are running, choose once per Nvim
		-- session and reuse that connection for subsequent prompts.
		url = function(callback)
			select_or_start_opencode_server(function(server)
				if server then
					require("opencode.config").opts.server.password = server.password
					callback(server.url)
				else
					callback(nil)
				end
			end, 5)
		end,
		start = start_opencode_tmux,
	},
	ask = {
		snacks = {
			win = {
				row = 1,
			},
		},
	},
}

local opencode = require("opencode")

local function ask_opencode(default, range)
	local Context = require("opencode.context")
	local context
	if range then
		context = setmetatable({
			buf = vim.api.nvim_get_current_buf(),
			win = vim.api.nvim_get_current_win(),
			cursor = vim.api.nvim_win_get_cursor(0),
			range = range,
		}, { __index = Context })
		Context.current = context
	else
		context = Context.new()
	end
	vim.ui.input({
		prompt = "Ask opencode: ",
		default = default,
	}, function(input)
		if input and input ~= "" then
			opencode.prompt(input, { context = context })
		end
	end)
end

vim.keymap.set("n", "<leader>oa", function()
	ask_opencode("@buffer: ")
end, { desc = "Ask opencode about the buffer" })

vim.keymap.set("x", "<leader>oa", function()
	local mode = vim.fn.mode()
	local kind = ({ v = "char", V = "line", ["\22"] = "block" })[mode]
	if not kind then
		return
	end
	local from = vim.api.nvim_buf_get_mark(0, "<")
	local to = vim.api.nvim_buf_get_mark(0, ">")
	if from[1] > to[1] or (from[1] == to[1] and from[2] > to[2]) then
		from, to = to, from
	end
	ask_opencode("@this: ", {
		from = { from[1], from[2] },
		to = { to[1], to[2] },
		kind = kind,
	})
end, { desc = "Ask opencode about the selection" })
