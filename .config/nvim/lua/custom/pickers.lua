local M = {}
---@module 'snacks.picker'

---@param opts? snacks.picker.Config
M.pick_repositories = function(opts)
  local script = [[
    find .. -maxdepth 2 -type d -name .git -exec sh -c '
          cd "{}"/.. &&
          branch=$(git branch --show-current) &&
          status=$(git status -bs) &&
          difference=$(echo "$status" | awk '"'"'/^##/ {ahead=0; behind=0; for(i=1; i<=NF; i++) {if ($i == "[ahead") {ahead=$(i+1)} else if ($i == "behind") {behind=$(i+1)}} if (ahead>0 || behind>0) printf "↑%d ↓%d", ahead, behind}'"'"') &&
          files=$(echo "$status"  | awk '"'"'/^ M / {m=1} /^?? / {u=1} END {if (m) printf "+"; if (u) printf "?"}'"'"') &&
          echo "$(pwd): $branch: $files $difference"' \; 2>/dev/null
  ]]
  local git_repo_heads = vim.fn.system(script)
  ---@type snacks.picker.finder.Item[]
  local items = {}
  for line in git_repo_heads:gmatch '[^\r\n]+' do
    local parts = {}
    for part in line:gmatch '[^:]+' do
      table.insert(parts, part)
    end
    local snack_item = {
      text = parts[1] .. '\t' .. parts[2] .. '\t' .. parts[3],
    }
    table.insert(items, snack_item)
  end

  return Snacks.picker(vim.tbl_extend('keep', opts or {}, {
    title = 'Git Respositories',
    items = items,
    sort = {
      fields = { 'idx' },
    },
    format = function(item, picker)
      local icon = '󰳏 '
      local icon_hl = 'NONE'

      local ret = {} ---@type snacks.picker.Highlight[]
      vim.list_extend(ret, Snacks.picker.format.tree(item, picker))
      table.insert(ret, { icon, icon_hl })
      Snacks.picker.highlight.format(item, item.text, ret)

      return ret
    end,
  }))
end

return M
