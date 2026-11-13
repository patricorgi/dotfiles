# .nopreview

Create an empty `.nopreview` file in a directory to disable file previews and
preview preloading there and in all descendant directories:

```sh
touch /path/to/folder/.nopreview
```

Remove the marker to restore previews. Move the cursor away and back to refresh
the preview after changing a marker. Directory listings and opening files are
unaffected. Existing preview caches are not deleted. Ancestors are checked along
the browsed path, not a symlink's resolved target path.

In `yazi.toml`, prefix file previewer and preloader commands with `nopreview`,
for example `run = "nopreview image"`. Keep directory previewers and existing
`noop` rules unchanged. New file previewer/preloader rules should use the same
prefix to respect the marker. No `init.lua` setup is needed.

For an optional previewer, set a fallback, e.g.
`run = "nopreview root-preview --fallback=code"`. If that plugin cannot be loaded,
the built-in code previewer is used instead. The marker is checked before either
plugin is loaded.
