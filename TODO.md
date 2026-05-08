# ArtificeLens TODOs

Updated: 2026-05-08

Open:
- Decide whether to set up trusted Developer ID signing/notarization or keep local ad-hoc signing only.
- Consider an experimental Logitech BRIO FoV control (`49e40215-f434-47fe-b158-0e885023e51b`, selector `0x05`) with read-before-write validation.
- Revisit local build strategy when full Xcode is available; current reliable build path is GitHub Actions plus local ad-hoc signing.
- Decide which local reports should remain private-only versus becoming sanitized project docs.
- Before committing the current rename work, stage the old project deletion together with the new `ArtificeLens.xcodeproj`.
- Verify Auto Exposure Priority, full exposure modes, Gamma/Iris, diagnostics export, still/timed capture, and preview zoom/pan behavior on the MX Brio from a full Xcode or GitHub Actions build.

Recently closed or reduced:
- Adapted the QUVCView/VVUVCKit research into native ArtificeLens improvements: generic UVC control metadata/diagnostics, stricter support/signedness handling, clamped profile writes, full UVC exposure modes, Gamma/Iris UI, local diagnostics export, still/timed capture, preview pinch/reset controls, and camera refresh.
- Normalized the app, helper, tests, project, scheme, CI, and visible strings from `ArtifceLens` to `ArtificeLens`.
- Added standard UVC Auto Exposure Priority plumbing and UI while keeping saved profiles backward-decodable.
- Kept firmware/AIT, EEPROM/test-debug, and unvalidated LED/PTZ vendor controls out of the normal UI; documented the boundary in code and security notes.
- Added Logi Tune-inspired slider value treatment: visible min/current/max values and `?` help tooltips across the main controls.
- Added a hover-revealed vertical zoom slider over the preview plus drag-to-pan/tilt behavior when zoomed in.
- Fixed profile apply to avoid force-unwrapping missing settings and made device removal match by camera `uniqueID`.
- Split ArtificeLens code, reports, evidence, chat-export space, and Dexter memory into `/Users/david/Codex/artificelens`.
- Created the ArtificeLens `dev` branch and completed initial hardening/stability work.
- Removed Sparkle/appcast update surface and vendored move-to-Applications helper from the fork.
- Fixed UVC descriptor parsing, first-launch usability, preview duplication, disconnect handling, and missing-control parsing issues discovered during MX Brio testing.
- Captured MX Brio standard/vendor UVC audit evidence and mapped safe/unsafe extension-control candidates.

Memory mirror:
- `/Users/david/Codex/dexter-memory/projects/artificelens/TODO.md`
