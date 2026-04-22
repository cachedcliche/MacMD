# Changelog

All notable changes to MacMD will be documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-04-21

### Fixed
- Adding or deleting a ` ``` ` fence line now re-highlights the affected region immediately. Previously, content whose fence membership changed kept its old styling until independently edited.
- Inline code block background color adapts correctly when the system appearance changes between Light and Dark Mode (wrapped in a dynamic `NSColor` provider so alpha resolves per-appearance).

### Changed
- Inline highlighting skips redundant string bridging (one `ts.string` fetch per edit instead of eleven), keeping typing smooth on larger documents.
- Bulk document replacements (open / external edit) no longer double-highlight the first paragraph before the full-document pass.
- `NSHumanReadableCopyright` set to "© 2026 Cached Cliché. MIT Licensed."
- Release DMG now uses APFS; packaging script cleans its staging directory even on failure.
- Regex compilation uses `try!` so any pattern bug surfaces with a real error.

### Added
- Two unit tests covering fence-boundary re-highlighting (adding and removing a fence marker). Total: 22 tests.

## [1.0.0] - 2026-04-20

### Added
- Document-based SwiftUI macOS app for editing `.md` files.
- Live syntax highlighting for headings (H1–H6), `**bold**`, `*italic*`, `` `code` ``, fenced code blocks (with open-block styling to end of document), `[links](url)`, ordered and unordered list markers, blockquotes, and horizontal rules.
- Correct composition of overlapping styles (e.g. `**bold *italic* bold**` shows bold and italic together; `> **bold**` preserves bold inside blockquote italic).
- Scoped paragraph-level re-highlighting so typing stays smooth on long documents.
- Dark Mode support via semantic `NSColor` values.
- UTF-8 read/write with explicit error on malformed encoding instead of silent replacement-character corruption.
- App Sandbox enabled; only `user-selected.read-write` file access. Hardened runtime on. No network, camera, mic, location, or contacts access.
- Custom app icon: black squircle with white `.MD` wordmark.
- 20 unit tests covering every syntax rule and the known composition edge cases.
