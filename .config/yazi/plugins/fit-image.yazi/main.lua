local M = {}

function M:show(job, source)
	local cache = ya.file_cache(job)
	if not cache or job.area.w == 0 or job.area.h == 0 then
		return ya.image_show(source, job.area)
	end

	local cw, ch = rt.term.cell_size()
	local width, height = rt.preview.max_width, rt.preview.max_height
	if cw and ch then
		width = math.max(1, math.floor(math.min(width, job.area.w * cw)))
		height = math.max(1, math.floor(math.min(height, job.area.h * ch)))
	end
	cache = Url(string.format("%s-fit-%dx%d.png", cache, width, height))
	if fs.cha(cache) then
		return ya.image_show(cache, job.area)
	end

	local info = ya.image_info(source)
	if not info then
		return ya.image_show(source, job.area)
	end
	local w, h = info.w, info.h
	if info.ori and info.ori >= 5 and info.ori <= 8 then
		w, h = h, w
	end
	-- Yazi already handles downscaling; only enlarge images that leave both edges unused.
	if w >= width or h >= height then
		return ya.image_show(source, job.area)
	end

	local temporary = Url(string.format("%s-%s.png", cache, ya.time()))
	local status, err = require("magick").with_limit()
		:arg({
			tostring(source) .. "[0]",
			"-auto-orient", "-resize", string.format("%dx%d", width, height),
			"-strip", "PNG:" .. tostring(temporary),
		})
		:status()
	if status and status.success then
		local ok
		ok, err = fs.rename(temporary, cache)
		if ok then
			return ya.image_show(cache, job.area)
		end
	end

	fs.remove("file", temporary)
	ya.dbg("Failed to enlarge preview", err or (status and status.code))
	return ya.image_show(source, job.area)
end

function M:peek(job)
	local start, source = os.clock(), ya.file_cache(job)
	if not source or not fs.cha(source) then
		source = job.file.url
	end
	ya.sleep(math.max(0, rt.preview.image_delay / 1000 + start - os.clock()))
	local _, err = self:show(job, source)
	ya.preview_widget(job, err)
end

function M:seek() end

return M
