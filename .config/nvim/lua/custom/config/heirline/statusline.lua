local components = require 'custom.config.heirline.components'

return { -- statusline
  components.RightPadding(components.Mode, 1),
  components.RightPadding(components.FileNameBlock, 1),
  components.RightPadding(components.Git, 1),
  components.RightPadding(components.Diagnostics, 1),
  components.RightPadding(components.Overseer, 1),
  components.RightPadding(components.SearchOccurrence, 0),
  components.Fill,
  components.MacroRecording,
  components.Fill,
  components.RightPadding(components.ShowCmd),
  -- components.RightPadding(components.LSPActive),
  components.RightPadding(components.LspProgress, 1),
  components.RightPadding(components.Formatters, 1),
  -- components.RightPadding(components.SimpleIndicator),
  components.RightPadding(components.FileType, 0),
  components.Ruler,
  -- components.ScrollBar,
}
