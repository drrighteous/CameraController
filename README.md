<h1 align="center"> ArtificeLens </h1>

<!-- subtext -->
<div align="center">
Advanced local camera control for macOS, focused on Logitech MX Brio-class UVC cameras.
</div>

<br/>

<div align="center">
    <img src="./.github/Basic.png" width="299" alt="basic screenshot"/>
    <img src="./.github/Preferences.png" width="299" alt="preferences screenshot"/>
</div>

## Status

ArtificeLens is a local/dev focused macOS UVC camera-control app while the UI, control coverage, signing, and release process are rebuilt.

## Installation

No public release channel is active yet. Build artifacts are produced from GitHub Actions and installed locally after checksum verification and local signing.

No Homebrew cask is used for ArtificeLens yet.

## Direction

- Logi Tune-style sliders with visible min/current/max values and help tooltips.
- Standard UVC Auto Exposure Priority plus full UVC exposure mode controls.
- Standard Gamma and Iris controls when exposed by the camera.
- Live-preview zoom overlay with pinch zoom, reset, and drag-to-pan/tilt when zoomed in.
- Local-only still capture, timed image capture, and JSON camera diagnostics export.
- Broader MX Brio UVC coverage while avoiding unsafe vendor-extension writes.
- Foreground-first behavior without bundled auto-updaters or privileged helper flows.

## Credit

ArtificeLens began from the open-source [CameraController](https://github.com/itaybre/CameraController) project by [Itay Brenner](https://github.com/itaybre). This rewrite keeps credit for that useful UVC foundation while moving the app identity, security posture, and feature direction to ArtificeLens.

## How to build

### Required

- Xcode
- [SwiftLint](https://github.com/realm/SwiftLint)

Clone the project
```sh
$ git clone git@github.com:drrighteous/ArtificeLens.git
$ cd ArtificeLens
```

Open `ArtificeLens.xcodeproj` with Xcode.

## FAQ

- Does it work with Apple's FaceTime Camera?

On older machines it may work, but newer Apple cameras can require private Apple entitlements. ArtificeLens is mainly being developed for external UVC cameras.

## Support
- macOS Monterey (`12.0`) and up.
- Works with cameras controllable via [UVC](https://www.usb.org/document-library/video-class-v15-document-set).

## Contributors
- Icons by [@herrerajeff](https://github.com/herrerajeff)
