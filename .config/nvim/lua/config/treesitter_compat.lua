local M = {}

local function has_directive(name)
	for _, directive in ipairs(vim.treesitter.query.list_directives()) do
		if directive == name then
			return true
		end
	end
	return false
end

function M.setup()
	if not vim.treesitter or not vim.treesitter.query or not vim.treesitter.query.add_directive then
		return
	end

	-- Some markdown injection queries from newer Neovim/nvim-treesitter releases use
	-- this directive, while older runtimes do not provide a handler for it. Register a
	-- small compatibility handler so render-markdown.nvim can parse markdown buffers
	-- without throwing: "No handler for set-lang-from-info-string!".
	if not has_directive("set-lang-from-info-string!") then
		vim.treesitter.query.add_directive("set-lang-from-info-string!", function(match, _, source, predicate, metadata)
			local capture = predicate[2]
			if type(capture) ~= "string" or capture:sub(1, 1) ~= "@" then
				return
			end

			local capture_name = capture:sub(2)
			for id, nodes in pairs(match) do
				if nodes and vim.treesitter.get_node_text and capture_name == "injection.language" then
					local node = type(nodes) == "table" and nodes[#nodes] or nodes
					if node then
						local ok, text = pcall(vim.treesitter.get_node_text, node, source)
						if ok and type(text) == "string" then
							local lang = text:match("^%s*[%{%.]*([%w_+-]+)")
							if lang then
								metadata["injection.language"] = lang:lower()
							end
						end
					end
				end
			end
		end, { all = true })
	end
end

return M
