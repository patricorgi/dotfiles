local M = {}

local set_target = ya.sync(function(state, url, target)
	state.url, state.target = url, target
end)

local function blocked(file)
	local directory = file.url.parent
	while directory do
		local marker = fs.cha(directory:join(".nopreview"), true)
		if marker and not marker.is_dir then
			return true
		end
		directory = directory.parent
	end
	return false
end

local function delegate(job)
	local target = table.remove(job.args, 1)
	assert(target and target ~= "nopreview", "nopreview requires a delegate plugin")
	local fallback = job.args.fallback
	job.args.fallback = nil
	if not fallback then
		return target, require(target)
	end

	-- Optional previewers may not be installed on every machine using these dotfiles.
	local ok, plugin = pcall(require, target)
	if ok then
		return target, plugin
	end
	assert(fallback ~= "nopreview", "nopreview cannot delegate to itself")
	return fallback, require(fallback)
end

function M:peek(job)
	if blocked(job.file) then
		set_target(tostring(job.file.url), nil)
		return ya.preview_widget(job, {})
	end

	local target, plugin = delegate(job)
	set_target(tostring(job.file.url), target)
	return plugin:peek(job)
end

function M:seek(job)
	-- Yazi's synchronous seek jobs do not include the previewer's arguments.
	if self.url == tostring(job.file.url) and self.target then
		return require(self.target):seek(job)
	end
end

function M:preload(job)
	if blocked(job.file) then
		-- Retry on a later preload pass so removing the marker re-enables caching.
		return false
	end
	local _, plugin = delegate(job)
	return plugin:preload(job)
end

return M
