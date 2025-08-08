return {
  'jake-stewart/multicursor.nvim',
  keys = { '<C-n>' },
  branch = '1.0',
  config = function()
    local mc = require 'multicursor-nvim'
    mc.setup()
    local set = vim.keymap.set
    -- Add or skip adding a new cursor by matching word/selection
    set({ 'n', 'v' }, '<C-n>', function()
      mc.matchAddCursor(1)
    end)
    set({ 'n', 'v' }, '<leader>s', function()
      mc.matchSkipCursor(1)
    end)
    set({ 'n', 'v' }, '<leader>N', function()
      mc.matchAddCursor(-1)
    end)
    set({ 'n', 'v' }, '<leader>S', function()
      mc.matchSkipCursor(-1)
    end)

    -- Add all matches in the document
    set({ 'n', 'v' }, '<leader>A', mc.matchAllAddCursors)

    -- Rotate the main cursor.
    set({ 'n', 'v' }, '<left>', mc.nextCursor)
    set({ 'n', 'v' }, '<right>', mc.prevCursor)

    -- Add and remove cursors with control + left click.
    set('n', '<c-leftmouse>', mc.handleMouse)

    -- Easy way to add and remove cursors using the main cursor.
    set({ 'n', 'v' }, '<c-q>', mc.toggleCursor)

    set('n', '<esc>', function()
      if not mc.cursorsEnabled() then
        mc.enableCursors()
      elseif mc.hasCursors() then
        mc.clearCursors()
      else
        -- Default <esc> handler.
        vim.cmd 'nohlsearch'
      end
    end)

    -- bring back cursors if you accidentally clear them
    set('n', '<leader>gv', mc.restoreCursors)

    -- Append/insert for each line of visual selections.
    set('v', 'I', mc.insertVisual)
    set('v', 'A', mc.appendVisual)

    -- match new cursors within visual selections by regex.
    set('v', 'M', mc.matchCursors)

    -- Jumplist support
    set({ 'v', 'n' }, '<c-i>', mc.jumpForward)
    set({ 'v', 'n' }, '<c-o>', mc.jumpBackward)

    -- Customize how cursors look.
    local hl = vim.api.nvim_set_hl
    hl(0, 'MultiCursorCursor', { link = 'Cursor' })
    hl(0, 'MultiCursorVisual', { link = 'Visual' })
    hl(0, 'MultiCursorSign', { link = 'SignColumn' })
    hl(0, 'MultiCursorDisabledCursor', { link = 'Visual' })
    hl(0, 'MultiCursorDisabledVisual', { link = 'Visual' })
    hl(0, 'MultiCursorDisabledSign', { link = 'SignColumn' })
  end,
}
