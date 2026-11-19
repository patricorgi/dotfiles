# Fit image, PDF, and video previews

`fit-image` enlarges small images to the largest size that fits the preview pane,
without cropping or changing their aspect ratio. `fit-pdf` applies the same
scaling to the built-in PDF renderer and keeps its page-navigation controls.
`fit-video` fits the built-in video thumbnails and preserves preview seeking.
The SSHFS PDF previewer also uses `fit-image` after rendering its page.

ImageMagick (`magick`) is required for enlargement. If conversion fails, the
original preview is displayed instead. Large images still use Yazi's built-in
downscaling. Originals are never modified; enlarged PNGs are cached separately
by file version, page or video seek position, and pane pixel dimensions, so
resizing the pane refits the preview. Transparency and EXIF orientation are
preserved.

All previewer rules retain the `nopreview` wrapper; background preloaders are
unchanged. No `init.lua` setup is needed. Restart Yazi after installation.

Run the focused tests from the dotfiles root:

```sh
nvim --headless -u NONE -i NONE -l scripts/tests/test_yazi_fit_image.lua
```
