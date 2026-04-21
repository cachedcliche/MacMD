# Scripts

## make_icon.swift

Regenerates the 10 app-icon PNGs (16, 32, 64, 128, 256, 512, 1024 px) directly into `MacMD/Assets.xcassets/AppIcon.appiconset/`. Uses CoreGraphics + CoreText — no external dependencies.

Run:

    swift Scripts/make_icon.swift MacMD/Assets.xcassets/AppIcon.appiconset

Then rebuild the app in Xcode (or via `xcodebuild`). The asset catalog picks up the new PNGs automatically.

Edit the script to change the icon — colors, font, corner radius, kerning are all local constants near the top.
