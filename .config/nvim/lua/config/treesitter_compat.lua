local M = {}

function M.setup()
	if not vim.treesitter or not vim.treesitter.query or not vim.treesitter.query.add_directive then
		return
	end

	-- Some markdown injection queries from newer Neovim/nvim-treesitter releases use
	-- this directive, while older runtimes do not provide a handler for it. Register a
	-- small compatibility handler so render-markdown.nvim can parse markdown buffers
	-- without throwing: "No handler for set-lang-from-info-string!".
	-- Re-register this after nvim-treesitter loads: its implementation assumes
	-- captures are TSNode objects, while Neovim 0.12 may return a node list.
	vim.treesitter.query.add_directive("set-lang-from-info-string!", function(match, _, source, predicate, metadata)
		local capture = predicate[2]
		if type(capture) ~= "string" or capture:sub(1, 1) ~= "@" then
			return
		end

		local node = match[capture:sub(2)] or match[predicate[2]]
		if type(node) == "table" then
			node = node[#node]
		end
		if not node or not vim.treesitter.get_node_text then
			return
		end

		local ok, text = pcall(vim.treesitter.get_node_text, node, source)
		if ok and type(text) == "string" then
			local lang = text:match("^%s*[%{%.]*([%w_+-]+)")
			if lang then
				metadata["injection.language"] = lang:lower()
			end
		end
	end, { all = true, force = true })
end

return M
