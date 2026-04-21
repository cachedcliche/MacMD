# MacMD — Project Reference

A single-file handoff document covering everything a future collaborator (or future you) needs to work on MacMD. Read this before the README when picking the project back up.

## Identity

- **Name**: MacMD
- **Version**: 1.0.0 (shipped 2026-04-20)
- **Description**: Simple, sandboxed macOS markdown editor with live syntax highlighting.
- **License**: MIT
- **Copyright holder**: Cached Cliché
- **GitHub org**: [cachedcliche](https://github.com/cachedcliche) (admin: patientbird)
- **Repo**: https://github.com/cachedcliche/MacMD
- **Latest release**: https://github.com/cachedcliche/MacMD/releases/latest

## Where things live

**On this machine**

    ~/Github/cached cliche/MacMD/     ← working tree (folder name has a space)

Note the parent directory is the human-readable `cached cliche` with a space. The GitHub org slug is `cachedcliche` (no space). Shell commands need quoting:

    cd "~/Github/cached cliche/MacMD"

**On GitHub**

    Repo:           cachedcliche/MacMD
    Default branch: main
    Tags:           v1.0.0
    Topics:         editor, mac-app, macos, markdown, swift, swiftui
    Homepage:       https://github.com/cachedcliche/MacMD/releases/latest
    Wiki:           disabled
    Issues:         enabled
    License:        MIT (auto-detected)

## Platform targets

- **Build**: Xcode 16+ (tested on Xcode 26.3)
- **Deployment target**: macOS 14 (Sonoma)
- **Tested on**: macOS 15 (Sequoia), macOS 26 (Tahoe)
- **Architectures**: universal (x86_64 + arm64)

## Architecture (one-screen summary)

SwiftUI document-based app. Six Swift files, ~500 lines of source.

    MacMDApp.swift            @main; DocumentGroup(newDocument:) — gives us
                              File > New/Open/Save/Save As/Duplicate/Recent +
                              autosave + versions for free.
    MarkdownDocument.swift    FileDocument conformance; UTF-8 read/write;
                              throws on malformed UTF-8 instead of silently
                              inserting U+FFFD replacement characters.
    DocumentView.swift        Thin SwiftUI wrapper around MarkdownTextView;
                              sets window frame defaults.
    MarkdownTextView.swift    NSViewRepresentable wrapping an NSTextView in
                              an NSScrollView. Rich text disabled. Coordinator
                              owns the highlighter; guards against feedback
                              loops via isUpdatingFromBinding; guards against
                              re-init via hasLoaded.
    MarkdownHighlighter.swift NSTextStorageDelegate. On every character edit,
                              expands to the paragraph range (or fenced span
                              if applicable), strips font/color/underline
                              attributes, reapplies base attrs + runs 11
                              regex rules.
    Theme.swift               Fonts, colors, paragraph style. Uses semantic
                              NSColors (labelColor, linkColor, etc.) so Dark
                              Mode adapts automatically.

Key design calls and why:

- `NSViewRepresentable` over `NSTextView` rather than SwiftUI's `TextEditor` — `TextEditor` can't set per-range attributes, so no syntax highlighting is possible.
- Highlight only the edited paragraph, not the whole document. Keeps typing smooth at 1MB+.
- Font trait composition via `NSFontManager.convert(_:toHaveTrait:)` — so `**bold *italic* bold**` renders with both traits instead of last-writer-wins. (Don't go back to replacing fonts — that breaks composition.)
- Fenced code blocks found via a full-document scan per keystroke. Intentional: the regex is trivial and sub-ms even at 500KB; caching would introduce invalidation bugs worse than the perf cost. Leave it.
- `UTImportedTypeDeclarations` for `net.daringfireball.markdown`, not `UTExportedTypeDeclarations`. Don't export a UTI your app didn't invent — it shadows other apps' registrations.

## Everyday commands

Run from the repo root (remember to quote the path):

    cd "~/Github/cached cliche/MacMD"

Build Debug:

    xcodebuild -project MacMD.xcodeproj -scheme MacMD -destination 'platform=macOS' build

Run the test suite (20 tests covering every highlighting rule + the edge cases):

    xcodebuild test -project MacMD.xcodeproj -scheme MacMD -destination 'platform=macOS'

Clean Release build + package as zip and DMG with sha256s:

    Scripts/package.sh 1.0.0

Regenerate the app icon (black squircle with white `.MD`):

    swift Scripts/make_icon.swift MacMD/Assets.xcassets/AppIcon.appiconset

Regenerate the GitHub social preview card:

    # (app must be running with a demo file open — see Scripts/make_social_preview.swift)

## Release process

1. Update `CHANGELOG.md` with the new version.
2. Bump `MARKETING_VERSION` in `MacMD.xcodeproj/project.pbxproj` (two places: app + tests).
3. Commit the changes.
4. Tag: `git tag vX.Y.Z`
5. Build artifacts: `Scripts/package.sh X.Y.Z` — produces `dist/*.zip`, `dist/*.dmg`, and their `.sha256` files.
6. Push: `git push origin main && git push origin vX.Y.Z`
7. Publish the release:
```
gh release create vX.Y.Z \
    dist/MacMD-X.Y.Z.dmg dist/MacMD-X.Y.Z.dmg.sha256 \
    dist/MacMD-X.Y.Z.zip dist/MacMD-X.Y.Z.zip.sha256 \
    --title "MacMD X.Y.Z" --notes-file CHANGELOG.md
```

## Code signing status

Currently **ad-hoc signed**, not Apple-notarized. This is fine for personal use and direct distribution. For App Store or for users who can't click through Gatekeeper, notarization requires:

- Apple Developer Program membership ($99/year).
- Developer ID Application certificate in Keychain.
- `codesign` with the Developer ID identity.
- `notarytool submit` to Apple.
- `stapler staple` the notarization ticket.

Not a 1.0 requirement. Users currently do the one-time Settings → Privacy & Security → Open Anyway dance (documented in `README.md`).

## Security posture

- Sandbox enabled (`com.apple.security.app-sandbox = true`).
- Only entitlement: `com.apple.security.files.user-selected.read-write`.
- No network, camera, mic, location, contacts, or Spotlight access.
- Hardened runtime enabled.
- `isRichText = false`, `importsGraphics = false`, smart quotes/dashes/replacements/autocorrect/link-detection all disabled — what the user types is byte-for-byte what is saved.

Verify from a built app:

    codesign -dv --entitlements - /Applications/MacMD.app

## Testing strategy

Unit tests only (`MacMDTests/MarkdownHighlighterTests.swift` — 20 tests). Coverage focus:

- Every regex rule produces correct attributes at known positions.
- Edge cases: unclosed fence, asterisk-list disambiguation, whitespace-adjacent delimiters, bold+italic composition, blockquote+bold composition, paragraph-style preservation, partial rehighlight after edit.

No UI/integration tests — the app is simple enough that the manual smoke test suffices.

## Project assets

    docs/screenshot.png         README hero image (1800x900, window-only capture)
    docs/social-preview.png     GitHub social card (1280x640, letterboxed on black)
    MacMD/Assets.xcassets/AppIcon.appiconset/   10 icon PNGs (16 to 1024 px)

Icon and social preview can be regenerated via Scripts/. Org avatar (cc mark, Roboto + coral #fa8072) was generated from a one-off script; if it needs regeneration, reuse `/tmp/make_cc_logo.swift` from session history or rebuild.

## Related context / memory

- Cached Cliché brand colors: text `#e5e5e5`, accent `#fa8072` (coral/salmon), background `#000`.
- Cached Cliché wordmark font: Roboto (Regular + Italic). Site source: https://cachedcliche.com.
- Org avatar uses `cc` — regular white + italic coral. Represents the org, not MacMD specifically.

## Known intentional limits

- No rendered preview pane.
- No toolbar, sidebar, word count, export-to-HTML, or front-matter handling.
- No multi-cursor editing (NSTextView supports it; we only preserve primary selection on external text updates).
- No CloudKit / iCloud sync.
- No notarization (see Code signing status above).

## Future ideas (if revisiting)

- Notarize for a polished "just double-click" install experience. Requires Apple Developer Program.
- Optional rendered preview in a split view (behind a preference, so the default remains TextEdit-like).
- Full markdown syntax support for tables, footnotes, task lists, nested emphasis edge cases.
- Dark/light theme toggle independent of system appearance.
- Word count / reading time in the window title or footer.
- Scope: Bluesky/Twitter sharing of excerpts directly from the app.

## Contact

- Author / maintainer: Evan Bean (GitHub: [patientbird](https://github.com/patientbird))
- Org: [Cached Cliché](https://cachedcliche.com)
- Questions or bug reports: https://github.com/cachedcliche/MacMD/issues
