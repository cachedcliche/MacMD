# Changelog

All notable changes to MacMD will be documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
