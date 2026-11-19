local M = {}

function M:peek(job)
	local start, cache = os.clock(), ya.file_cache(job)
	if not cache then
		return
	end

	local ok, err = require("video"):preload(job)
	if not ok or err then
		return ya.preview_widget(job, err)
	end

	ya.sleep(math.max(0, rt.preview.image_delay / 1000 + start - os.clock()))
	local _, err = require("fit-image"):show(job, cache)
	ya.preview_widget(job, err)
end

function M:seek(job)
	require("video"):seek(job)
end

return M
