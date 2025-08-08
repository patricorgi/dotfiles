--- @sync entry
local function entry(_, job)
	local parent = cx.active.parent
	if not parent then return end

	local target = parent.files[parent.cursor + 1 + job.args[1]]
	if target and target.cha.is_dir then
		ya.mgr_emit("cd", { target.url })
	end
end

return { entry = entry }
