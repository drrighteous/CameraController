# CameraController Fork Security Audit Notes

Branch: `dev`

This fork is intended for local, controlled builds of CameraController. The first hardening pass focused on reducing implicit trust, removing unattended network/update behavior, and improving USB/camera lifecycle safety.

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

## Security Posture

The fork should not make update-network calls by default. It should not run bundled shell scripts or privileged install/move flows. The app remains sandboxed with camera and USB entitlements because UVC camera control requires those capabilities.

## Remaining Review Items

- Build, sign, and notarization should be handled by a trusted release process before broad distribution.
- The login item still uses the legacy helper target because the app supports macOS 12. A future macOS 13+ only fork could migrate to `SMAppService`.
- The app still uses the upstream bundle identifier. Changing it would isolate TCC permissions but would require new helper identifiers and user permission prompts.
- UVC control operations still depend on low-level IOKit APIs. Continue testing with the target Logitech BRIO hardware after each USB-layer change.
