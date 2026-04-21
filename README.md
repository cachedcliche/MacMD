# MacMD

A simple, clean, secure markdown editor for macOS. Feels like TextEdit, but for `.md` files and with live syntax highlighting.

Built for editing claude.md, skill definitions, agent configs, READMEs, and similar small-to-medium markdown files.

![MacMD screenshot](docs/screenshot.png)

## Run it

Double-click `MacMD.app`. That's it.

First launch on a fresh Mac may show a Gatekeeper prompt because the app is ad-hoc signed (not notarized). To bypass it:

    right-click MacMD.app → Open → Open

macOS will remember the choice for future launches.

Minimum macOS version: 14 (Sonoma).

## Write and save

File menu works exactly as you'd expect. All commands use standard Mac keybindings.

    Cmd-N     New document
    Cmd-O     Open an existing .md file
    Cmd-S     Save (prompts for filename + location on first save)
    Cmd-Shift-S   Save As
    Cmd-W     Close window (prompts to save if dirty)
    Cmd-Z / Cmd-Shift-Z   Undo / Redo
    Cmd-F     Find (inline find bar)
    Cmd-,     Preferences (none yet — App does nothing on this shortcut)

The editor autosaves in the background. If the app quits unexpectedly, reopening recovers your work. Recent files appear under `File → Open Recent`.

## What gets highlighted

As you type, MacMD styles these markdown constructs live:

    # Heading 1 through ###### Heading 6   — bold, accent color, sized per level
    **bold** and __bold__                  — bold
    *italic* and _italic_                  — italic
    ***bold italic***                      — bold + italic compose correctly
    `inline code`                          — subtle background tint
    ```                                    — fenced code blocks get the same tint,
    fenced code                               and style to end of document if you
    ```                                       haven't closed them yet
    [link label](https://example.com)      — label underlined in link color, URL muted
    - unordered, * and + also valid        — marker in accent color
    1. ordered list                        — marker in accent color
    > blockquote                           — muted + italic, composes with bold inside
    ---                                    — muted

Highlighting updates only the paragraph you're editing, so typing stays smooth on long files. Inside fenced code blocks, inline rules are intentionally suppressed — code stays code.

Semantic colors are used throughout, so Dark Mode adapts automatically when you toggle system appearance.

## What gets saved

Plain UTF-8 text. Byte-for-byte what you typed — no smart quotes, no dash substitution, no link detection, no autocorrect. Paste from another app always comes in as plain text.

If you try to open a file that isn't valid UTF-8, MacMD refuses and surfaces a clear error rather than silently corrupting it with replacement characters.

## Security

MacMD is sandboxed. It has access only to:

    Files you explicitly open or save to (user-selected read/write).

It has no network access, no access to the camera, microphone, location, photos, contacts, calendars, or Spotlight indexing. It doesn't register any URL schemes or services. The hardened runtime is enabled.

You can verify at any time:

    codesign -dv --entitlements - /path/to/MacMD.app

## Build from source

Requires Xcode 16 or newer.

    xcodebuild -project MacMD.xcodeproj -scheme MacMD -configuration Release -destination 'platform=macOS' build

The built app lands in Xcode's DerivedData under `Build/Products/Release/MacMD.app`, or you can open the project in Xcode and press Cmd-R to run it directly.

Run tests:

    xcodebuild test -project MacMD.xcodeproj -scheme MacMD -destination 'platform=macOS'

There are 20 unit tests covering every syntax highlighting rule and the tricky edge cases (bold+italic composition, unclosed code fences, list-marker vs italic disambiguation, paragraph-style preservation).

### Produce a release bundle

    Scripts/package.sh 1.0.0

This runs a clean Release build, zips `MacMD.app` via `ditto` (signature-preserving), writes `dist/MacMD-1.0.0.zip`, and a matching `.sha256` file. Upload both to the GitHub release page.

## Project layout

    MacMD/
      README.md                   This file
      LICENSE                     MIT
      CHANGELOG.md                Version history
      .gitignore
      MacMD.xcodeproj/            Xcode project
      MacMD/                      Source
        MacMDApp.swift            Entry point; @main; DocumentGroup
        MarkdownDocument.swift    FileDocument; UTF-8 read/write
        DocumentView.swift        Thin SwiftUI wrapper around the text view
        MarkdownTextView.swift    NSViewRepresentable wrapping NSTextView
        MarkdownHighlighter.swift NSTextStorageDelegate; regex rules
        Theme.swift               Fonts, colors, paragraph style
        Info.plist                Document types, UTI declarations
        MacMD.entitlements        Sandbox; user-selected files R/W
        Assets.xcassets/          AppIcon + AccentColor
      MacMDTests/
        MarkdownHighlighterTests.swift
      Scripts/
        README.md
        make_icon.swift           Regenerates the app icon PNGs
        package.sh                Builds Release and zips into dist/
      docs/
        screenshot.png
      dist/                       (gitignored) release artifacts go here

## Known intentional limits

No live rendered preview pane. No toolbar. No theming UI. No word count, export to HTML, or front-matter handling. The goal is "simple like TextEdit, but for markdown" — anything beyond that is out of scope.

No multi-cursor editing (NSTextView supports it; MacMD preserves only the primary selection through external text updates). No outline pane, no file browser.
