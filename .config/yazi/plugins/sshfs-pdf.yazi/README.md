# SSHFS PDF preview

Used only for PDFs under `/Users/patricorgi/SSHFS/` (Yazi's URL matching is
case-insensitive, so `.PDF` is included).

- Waits 150 ms before remote I/O so fast navigation skips intermediate files.
- Renders only the hovered page asynchronously, capped at 1600 pixels on its
  longest side. Yazi cancels the preview and its converter when the cursor moves.
- Checks the hovered PDF's modification time and size every two seconds and
  renders a fresh cache entry when they change. Failed conversions are retried.
- Keeps the normal PDF page-scrolling controls. Local PDFs use the built-in
  previewer unchanged; SSHFS background preloading is disabled.

The SSHFS mount's five-second metadata cache can delay detecting remote changes;
allow roughly seven seconds after a completed write. Changes that preserve both
modification time and size cannot be detected by this metadata-only check.
