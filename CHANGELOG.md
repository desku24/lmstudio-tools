# Changelog

All notable changes to this project will be documented in this file.

## v0.2.0

### Added
- FUSE2 check: warns if `libfuse.so.2` is missing (does not abort)
- Sandbox check: detects disabled user namespaces and hints at `--no-sandbox`
- `libfuse2t64` listed in requirements

### Changed
- `.desktop` icon set to `application-x-executable` (works on all systems)
- FUSE fallback in `lmstudio-latest` now checks `ldconfig` instead of `fusermount`

### Removed
- `--arch` option (focus on x86_64 only)
- `--format deb` option (focus on AppImage only)

---

## v0.1.0

### Added
- Initial public release
- `lmstudio-update` for downloading and updating to the latest LM Studio AppImage version
- `lmstudio-latest` for launching the newest installed version
- optional symlink support
- optional `.desktop` launcher creation
- optional automation via cron
- `install.sh` for installation into `~/.local/bin`

### Changed
- documentation streamlined and focused clearly on the AppImage workflow

### Removed
- references to untested package formats such as `.deb` and Arch removed

### Notes
- current focus is Linux with AppImage
- no cryptographic verification of downloads
