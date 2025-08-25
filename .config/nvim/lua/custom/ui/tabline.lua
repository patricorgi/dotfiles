-- in your init.lua
vim.o.tabline = "%!v:lua.MyTabline()"

function _G.MyTabline()
  local s = ""
  for i = 1, vim.fn.tabpagenr('$') do
    local winnr = vim.fn.tabpagewinnr(i)
    local buflist = vim.fn.tabpagebuflist(i)
    local bufnr = buflist[winnr]
    local name = vim.fn.fnamemodify(vim.fn.bufname(bufnr), ':t')
    if name == "" then name = "[No Name]" end

    if i == vim.fn.tabpagenr() then
      s = s .. "%#TabLineSel#"
    else
      s = s .. "%#TabLine#"
    end

    -- tab label
    s = s .. " " .. i .. ":" .. name .. " "

    -- clickable close button (here we use "✖")
    s = s .. "%999X✗%X "
  end
  s = s .. "%#TabLineFill#"

  return s
end
