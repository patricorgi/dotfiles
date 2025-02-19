local header = [[
░  ░░░░░░░░  ░░░░  ░░░      ░░░  ░░░░░░░
▒  ▒▒▒▒▒▒▒▒  ▒▒▒▒  ▒▒  ▒▒▒▒  ▒▒  ▒▒▒▒▒▒▒
▓  ▓▓▓▓▓▓▓▓        ▓▓  ▓▓▓▓▓▓▓▓       ▓▓
█  ████████  ████  ██  ████  ██  ████  █
█        ██  ████  ███      ███       ██
]]
local cwd = vim.fn.getcwd(0)
if cwd and cwd:find 'Obsidian' then
  header = [[
                   ----                 
                --------                
              ----------  --            
           ------------  -----          
        -------------   -------         
       -------------   ----------       
       ------------   ------------      
       ------------  -------------      
        -----------  -------------      
      -   ---------  --------------     
     ----  --------  --------------     
    ------   ------   ---------------   
   --------   -----     --------------  
  ----------      ------     -----------
 ------------  --------------   --------
-------------  ----------------   ----  
 ------------  ------------------  --   
   ----------  -------------------      
      ------  --------------------      
        ---   -------------------       
            ---------------------       
                       ---------        
  ]]
end

---@diagnostic disable: missing-fields
require('snacks').setup {
  notifier = {},
  picker = {
    matcher = { frecency = true, cwd_bonus = true, history_bonus = true },
    formatters = { icon_width = 3 },
    -- win = { input = { keys = { ['<Esc>'] = { 'close', mode = { 'n', 'i' } } } } },
  },
  dashboard = {
    preset = {
      keys = {
        { icon = '󰈞 ', key = 'f', desc = 'Find files', action = ':lua Snacks.picker.smart()' },
        { icon = ' ', key = 'o', desc = 'Find history', action = 'lua Snacks.picker.recent()' },
        { icon = ' ', key = 'e', desc = 'New file', action = ':enew' },
        { icon = ' ', key = 'o', desc = 'Recent files', action = ':lua Snacks.picker.recent()' },
        { icon = '󰒲 ', key = 'L', desc = 'Lazy', action = ':Lazy', enabled = package.loaded.lazy ~= nil },
        { icon = '󰔛 ', key = 'P', desc = 'Lazy Profile', action = ':Lazy profile', enabled = package.loaded.lazy ~= nil },
        { icon = ' ', key = 'M', desc = 'Mason', action = ':Mason', enabled = package.loaded.lazy ~= nil },
        { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
      },
      header = header,
    },
    sections = {
      { section = 'header' },
      { icon = ' ', title = 'Keymaps', section = 'keys', indent = 2, padding = 1 },
    },
  },
  image = {
    enabled = true,
    doc = { enabled = true, inline = false, float = true, max_width = 40, max_height = 30 },
    resolve = function(_, src)
      local vault_path = vim.fn.expand '~' .. '/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault'

      -- when the file path is *attachments/*
      local att_path = src:match '(attachments/.*)'
      if att_path then
        return vault_path .. '/' .. att_path
      end

      -- when the file path is pure basename without any directory component
      if not src:match '[/\\]' then
        return vault_path .. '/attachments/' .. src
      end

      -- when the file path is absolute path
      if src:match '^/' then
        return src
      end

      return src
    end,
  },
  indent = {
    enabled = false,
    indent = { enabled = false },
    animate = { duration = { step = 10, duration = 100 } },
    scope = { enabled = true, char = '┊', underline = false, only_current = true, priority = 1000 },
  },
  styles = {
    snacks_image = {
      border = 'rounded',
      backdrop = false,
    },
  },
  -- statuscolumn = {
  --   left = { 'mark', 'git' },
  --   right = {},
  --   folds = { open = true, git_hl = true },
  --   git = { patterns = { 'GitSign', 'MiniDiffSign' } },
  -- },
}
