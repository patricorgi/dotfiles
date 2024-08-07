local components = require 'custom.config.heirline.components'

return { -- statusline
  components.RightPadding(components.Mode, 2),
  components.RightPadding(components.FilePathBlock, 2),
  components.RightPadding(components.Git, 2),
  components.RightPadding(components.Diagnostics),
  components.RightPadding(components.SearchOccurrence),
  components.Fill,
  components.MacroRecording,
  components.Fill,
  components.RightPadding(components.ShowCmd),
  components.RightPadding(components.LSPActive),
  components.RightPadding(components.FileType, 0),
  components.RightPadding(components.Overseer, 0),
  components.RightPadding(components.Ruler),
  components.ScrollBar,
}
