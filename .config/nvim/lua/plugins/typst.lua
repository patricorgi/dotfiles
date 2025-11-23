vim.api.nvim_create_user_command("TypstPreview", function(opts)
	vim.pack.add({
		{ src = "https://github.com/chomosuke/typst-preview.nvim" },
	})

	local open_cmd = [[osascript -e '
tell application "BetterTouchTool" to execute_assigned_actions_for_trigger "954AB122-3DE2-4D47-864D-734D70412D12"
set targetURL to "%s"
if targetURL ends with "/" then
	set targetURL to text 1 thru -2 of targetURL
end if
tell application "Safari"
	activate
	set foundTab to false
	repeat with w in windows
		repeat with t in tabs of w
			set theURL to (URL of t as text)
			if theURL ends with "/" then
				set theURL to text 1 thru -2 of theURL
			end if
			if theURL is targetURL then
				set current tab of w to t
				set index of w to 1
				set foundTab to true
				exit repeat
			end if
		end repeat
		if foundTab then exit repeat
	end repeat
	if not foundTab then
		make new document with properties {URL:targetURL}
	end if
end tell
delay 1
tell application "BetterTouchTool" to execute_assigned_actions_for_trigger "F3A75484-18DF-4B5C-8E26-9D98BF1FB3E1"
tell application "kitty" to activate
']]

	require("typst-preview").setup({
		open_cmd = open_cmd,
	})
	-- Re-run the original command
	vim.cmd({
		cmd = "TypstPreview",
		args = opts.fargs,
		bang = opts.bang,
	})
end, {
	nargs = "*",
	bang = true,
	desc = "Lazy-load typst-preview.nvim",
})
