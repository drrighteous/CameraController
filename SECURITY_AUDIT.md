# ArtificeLens Security Audit Notes

Branch: `dev`

ArtificeLens is intended for local, controlled builds while the app identity, UI, UVC control coverage, signing, and release process are rebuilt. The first hardening pass focused on reducing implicit trust, removing unattended network/update behavior, and improving USB/camera lifecycle safety.

## Changes Made

- Removed Sparkle auto-update integration from the app target.
- Removed the upstream appcast and Sparkle plist keys.
- Removed Sparkle mach lookup sandbox exceptions from app entitlements.
- Removed the vendored move-to-Applications helper code that could run shell/admin copy behavior.
- Changed the menu-bar UI from a popover to a normal app window so it can be opened and focused reliably.
- Added app reopen handling so launching the app can bring the controls forward.
- Hardened USB interface discovery by avoiding force unwraps and releasing IOKit iterators/candidates.
- Ensured legacy USB request paths close interfaces even when requests fail.
- Fixed camera preview layer reuse and moved capture session start/stop work onto a serial queue.
- Fixed device observer cleanup and removed a force unwrap in device removal handling.
- Prevented duplicate camera entries on repeated device connect notifications.
- Added Hue and Roll to profile save/restore while keeping older saved profiles decodable.
- Updated the login helper to use the modern `NSWorkspace` open API and exit after launch.
- Kept normal UI control exposure limited to standard UVC camera-terminal and processing-unit controls. Firmware/AIT, EEPROM/test-debug, and unvalidated LED/PTZ vendor extension selectors are intentionally not surfaced.
- Added local-only still capture, timed capture, and diagnostics export. These flows write only to user-selected files/folders through macOS panels and do not add network or updater surfaces.

## Security Posture

The app should not make update-network calls by default. It should not run bundled shell scripts or privileged install/move flows. The app remains sandboxed with camera and USB entitlements because UVC camera control requires those capabilities.

## Remaining Review Items

- Build, sign, and notarization should be handled by a trusted release process before broad distribution.
- The login item still uses the legacy helper target because the app supports macOS 12. A future macOS 13+ only fork could migrate to `SMAppService`.
- The app now uses the fork-specific bundle identifier `com.drrighteous.ArtificeLens`; macOS will treat it as a new app for TCC/camera permissions.
- UVC control operations still depend on low-level IOKit APIs. Continue testing with the target Logitech BRIO hardware after each USB-layer change.
