local M = {}

local function version(cha)
	return string.format("%.9f:%d", cha.mtime or 0, cha.len)
end

function M:render(job)
	local cache = ya.file_cache(job)
	if not cache then
		return false
	end
	-- Keep these bounded renders separate from the built-in PDF cache.
	cache = Url(tostring(cache) .. "-sshfs-1600.jpg")
	if not fs.cha(cache) then
		local prefix = tostring(cache) .. "-" .. tostring(ya.time())
		local temporary = Url(prefix .. ".jpg")
		local output, err = Command("pdftoppm")
			:arg({
				"-f", tostring(job.skip + 1),
				"-l", tostring(job.skip + 1),
				"-singlefile", "-scale-to", "1600",
				"-jpeg", "-jpegopt", "quality=" .. rt.preview.image_quality,
				tostring(job.file.path), prefix,
			})
			:output()

		if not output or not output.status.success then
			fs.remove("file", temporary)
			local pages = output and job.skip > 0 and tonumber(output.stderr:match("the last page %((%d+)%)"))
			if pages and pages > 0 then
				ya.emit("peek", { pages - 1, only_if = job.file.url, upper_bound = true })
			else
				ya.preview_widget(job, Err("Failed to render SSHFS PDF: %s", output and output.stderr or err))
			end
			return false
		end

		-- A PDF may be replaced while pdftoppm is reading it. Retry on the next poll.
		local current = fs.cha(job.file.url, true)
		if not current or version(current) ~= version(job.file.cha) then
			fs.remove("file", temporary)
			return false
		end
		local ok, rename_err = fs.rename(temporary, cache)
		if not ok then
			fs.remove("file", temporary)
			ya.preview_widget(job, rename_err)
			return false
		end
	end

	local _, err = ya.image_show(cache, job.area)
	ya.preview_widget(job, err)
	return err == nil
end

function M:peek(job)
	-- Debounce before any remote I/O; Yazi cancels this job when the cursor moves.
	ya.sleep(0.15)
	local shown
	while true do
		local cha = fs.cha(job.file.url, true)
		if cha and cha.len > 0 and version(cha) ~= shown then
			job.file = File({ url = job.file.url, cha = cha })
			if self:render(job) then
				shown = version(cha)
			end
		end
		ya.sleep(2)
	end
end

function M:seek(job)
	local h = cx.active.current.hovered
	if h and h.url == job.file.url then
		local step = ya.clamp(-1, job.units, 1)
		ya.emit("peek", { math.max(0, cx.active.preview.skip + step), only_if = job.file.url })
	end
end

return M
