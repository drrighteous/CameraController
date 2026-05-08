//
//  ContentView.swift
//  ArtificeLens
//
//

import SwiftUI
import Combine
import AVFoundation
import AppKit
import UniformTypeIdentifiers

struct ContentView: View {
    @ObservedObject var manager = DevicesManager.shared
    @ObservedObject var settings = UserSettings.shared
    @State var currentSection: Int? = 0

    var body: some View {
        HStack {
            VStack(spacing: 0) {
                cameraPreview()
                    .animation(nil)

                TabSelectorView(selectedIndex: $currentSection)
                    .padding(.vertical, Constants.Style.padding)
                    .animation(nil)

                settingsView()
            }.onAppear {
                DevicesManager.shared.startMonitoring()
            }.onDisappear {
                DevicesManager.shared.stopMonitoring()
            }
            .frame(width: settings.cameraPreviewSize.getWidth() - Constants.Style.padding * 2)
        }
        .fixedSize()
        .background(
            VisualEffectView(material: .hudWindow,
                             blendingMode: .behindWindow,
                             state: .active)
        )
    }

    @ViewBuilder
    func cameraPreview() -> some View {
        if settings.hideCameraPreview {
            EmptyView()
        } else if $manager.selectedDevice.wrappedValue != nil {
            CameraPreviewSurface(captureDevice: $manager.selectedDevice,
                                 mirrorPreview: settings.mirrorPreview)
                .frame(
                    width: settings.cameraPreviewSize.getWidth(),
                    height: settings.cameraPreviewSize.getHeight()
                )
        } else {
            Image("video.slash")
                .frame(
                    width: settings.cameraPreviewSize.getWidth(),
                    height: settings.cameraPreviewSize.getHeight()
                )
                .background(Color.gray)
        }
    }

    @ViewBuilder
    func settingsView() -> some View {
        SettingsView(
            captureDevice: $manager.selectedDevice,
            currentSection: $currentSection
        )
    }
}

private struct CameraPreviewSurface: View {
    @Binding var captureDevice: CaptureDevice?
    let mirrorPreview: Bool

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            CameraPreview(captureDevice: $captureDevice)
                .scaleEffect(CGSize(width: mirrorPreview ? -1 : 1, height: 1))

            if let controller = captureDevice?.controller {
                PreviewZoomOverlay(controller: controller)
            }

            if captureDevice?.avDevice != nil {
                PreviewCaptureOverlay()
                    .padding(10)
            }
        }
        .clipped()
    }
}

private struct PreviewZoomOverlay: View {
    @ObservedObject private var zoom: NumberCaptureDeviceProperty
    @ObservedObject private var panTilt: MultipleCaptureDeviceProperty
    @State private var isHovering = false
    @State private var dragStartPan: Float?
    @State private var dragStartTilt: Float?
    @State private var magnifyStartZoom: Float?

    init(controller: DeviceController) {
        self.zoom = controller.zoomAbsolute
        self.panTilt = controller.panTiltAbsolute
    }

    private var canPanTilt: Bool {
        zoom.isCapable && panTilt.isCapable && zoom.sliderValue > zoom.minimum
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .trailing) {
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(panTiltGesture(in: proxy.size), including: canPanTilt ? .all : .none)
                    .simultaneousGesture(zoomGesture(), including: zoom.isCapable ? .all : .none)
                    .simultaneousGesture(TapGesture(count: 2).onEnded(resetPreview),
                                         including: zoom.isCapable ? .all : .none)
                    .allowsHitTesting(zoom.isCapable || canPanTilt)

                if zoom.isCapable {
                    zoomControl
                        .padding(.trailing, 10)
                        .opacity(isHovering ? 1 : 0)
                        .allowsHitTesting(isHovering)
                        .animation(.easeInOut(duration: 0.16), value: isHovering)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onHover { hovering in
                isHovering = hovering
            }
        }
    }

    private var zoomControl: some View {
        VStack(spacing: 6) {
            Image(systemName: "plus.magnifyingglass")
                .font(.system(size: 13, weight: .semibold))

            VerticalZoomSlider(value: $zoom.sliderValue,
                               step: zoom.resolution,
                               range: zoom.minimum...zoom.maximum)
                .frame(width: 22, height: 150)

            HStack(spacing: 4) {
                Text(formatted(zoom.sliderValue))
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .monospacedDigit()

                Button {
                    resetPreview()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.caption2)
                }
                .buttonStyle(.borderless)
                .help("Reset zoom, pan, and tilt.")
            }
        }
        .foregroundColor(Constants.Colors.regularColor)
        .padding(.horizontal, 7)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.42))
        .cornerRadius(8)
        .help("Drag to zoom. When zoomed in, drag the preview to pan and tilt.")
    }

    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { scale in
                if magnifyStartZoom == nil {
                    magnifyStartZoom = zoom.sliderValue
                }

                let range = zoom.maximum - zoom.minimum
                let nextValue = (magnifyStartZoom ?? zoom.sliderValue) + (Float(scale) - 1) * range * 0.45
                zoom.sliderValue = stepped(clamped(nextValue, in: zoom.minimum...zoom.maximum),
                                           step: zoom.resolution)
            }
            .onEnded { _ in
                magnifyStartZoom = nil
            }
    }

    private func panTiltGesture(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 1, coordinateSpace: .local)
            .onChanged { gesture in
                if dragStartPan == nil {
                    dragStartPan = panTilt.sliderValue1
                    dragStartTilt = panTilt.sliderValue2
                }

                let width = max(Float(size.width), 1)
                let height = max(Float(size.height), 1)
                let panRange = panTilt.maximum1 - panTilt.minimum1
                let tiltRange = panTilt.maximum2 - panTilt.minimum2

                let pan = (dragStartPan ?? panTilt.sliderValue1)
                    + Float(gesture.translation.width) / width * panRange
                let tilt = (dragStartTilt ?? panTilt.sliderValue2)
                    - Float(gesture.translation.height) / height * tiltRange

                panTilt.sliderValue1 = stepped(clamped(pan, in: panTilt.minimum1...panTilt.maximum1),
                                               step: panTilt.resolution1)
                panTilt.sliderValue2 = stepped(clamped(tilt, in: panTilt.minimum2...panTilt.maximum2),
                                               step: panTilt.resolution2)
            }
            .onEnded { _ in
                dragStartPan = nil
                dragStartTilt = nil
            }
    }

    private func resetPreview() {
        zoom.sliderValue = zoom.minimum

        guard panTilt.isCapable else {
            return
        }

        panTilt.sliderValue1 = panTilt.defaultValue1
        panTilt.sliderValue2 = panTilt.defaultValue2
    }

    private func clamped(_ value: Float, in range: ClosedRange<Float>) -> Float {
        min(max(value, range.lowerBound), range.upperBound)
    }

    private func stepped(_ value: Float, step: Float) -> Float {
        guard step > 0 else { return value }
        return value - value.truncatingRemainder(dividingBy: step)
    }

    private func formatted(_ value: Float) -> String {
        if value.rounded() == value {
            return String(Int(value))
        }

        return String(format: "%.1f", value)
    }
}

private struct PreviewCaptureOverlay: View {
    @State private var isSequenceRunning = false
    @State private var sequenceTimer: Timer?
    @State private var sequenceFolder: URL?
    @State private var sequenceFolderAccessed = false
    @State private var captureStatus: String?
    @State private var captureSucceeded = true

    private let sequenceInterval: TimeInterval = 5

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 8) {
                Button {
                    saveStill()
                } label: {
                    Image(systemName: "camera")
                        .font(.system(size: 14, weight: .semibold))
                }
                .buttonStyle(.borderless)
                .help("Save a local still image.")

                Button {
                    isSequenceRunning ? stopSequence() : chooseSequenceFolder()
                } label: {
                    Image(systemName: isSequenceRunning ? "timer.circle.fill" : "timer")
                        .font(.system(size: 14, weight: .semibold))
                }
                .buttonStyle(.borderless)
                .help(isSequenceRunning ? "Stop timed local capture." : "Save a local still every 5 seconds.")
            }

            if let captureStatus {
                Text(captureStatus)
                    .font(.caption2)
                    .lineLimit(1)
                    .foregroundColor(captureSucceeded ? Constants.Colors.regularColor.opacity(0.78) : .red.opacity(0.9))
            }
        }
        .foregroundColor(Constants.Colors.regularColor)
        .padding(.horizontal, 9)
        .padding(.vertical, 7)
        .background(Color.black.opacity(0.42))
        .cornerRadius(8)
        .onDisappear {
            stopSequence()
        }
        .onReceive(NotificationCenter.default.publisher(for: .captureStillCompleted)) { notification in
            captureStatus = notification.userInfo?["message"] as? String
            captureSucceeded = notification.userInfo?["success"] as? Bool ?? true
        }
    }

    private func saveStill() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.jpeg]
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = "\(timestamp()).jpg"

        panel.begin { response in
            guard response == .OK, let url = panel.url else {
                return
            }

            requestCapture(to: url)
        }
    }

    private func chooseSequenceFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false

        panel.begin { response in
            guard response == .OK, let folder = panel.url else {
                return
            }

            sequenceFolder = folder
            sequenceFolderAccessed = folder.startAccessingSecurityScopedResource()
            startSequence()
        }
    }

    private func startSequence() {
        guard sequenceTimer == nil else {
            return
        }

        isSequenceRunning = true
        captureSequenceFrame()

        let timer = Timer(timeInterval: sequenceInterval, repeats: true) { _ in
            captureSequenceFrame()
        }
        sequenceTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func stopSequence() {
        sequenceTimer?.invalidate()
        sequenceTimer = nil
        isSequenceRunning = false
        if sequenceFolderAccessed {
            sequenceFolder?.stopAccessingSecurityScopedResource()
            sequenceFolderAccessed = false
        }
    }

    private func captureSequenceFrame() {
        guard let sequenceFolder else {
            stopSequence()
            return
        }

        requestCapture(to: sequenceFolder.appendingPathComponent("\(timestamp()).jpg"))
    }

    private func requestCapture(to url: URL) {
        NotificationCenter.default.post(name: .captureStillRequested,
                                        object: nil,
                                        userInfo: ["url": url])
    }

    private func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss-SSS"
        return "ArtificeLens-\(formatter.string(from: Date()))"
    }
}

private struct VerticalZoomSlider: View {
    @Binding var value: Float
    let step: Float
    let range: ClosedRange<Float>
    let minTrackColor: Color = Constants.Colors.accentColor
    let maxTrackColor: Color = Constants.Colors.sliderBackground
    let thumbColor: Color = Constants.Colors.activeThumbSlider

    var body: some View {
        GeometryReader { geometry in
            let thumbSize = geometry.size.width
            let availableHeight = max(geometry.size.height - thumbSize, 1)
            let percent = CGFloat(percentage(for: value))
            let thumbOffset = (1 - percent) * availableHeight
            let activeHeight = percent * availableHeight + thumbSize / 2

            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: thumbSize / 2)
                    .foregroundColor(maxTrackColor)

                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: thumbSize / 2)
                        .foregroundColor(minTrackColor)
                        .frame(height: activeHeight)
                }

                VStack {
                    RoundedRectangle(cornerRadius: thumbSize / 2)
                        .foregroundColor(thumbColor)
                        .frame(width: thumbSize, height: thumbSize)
                        .shadow(radius: 4)
                        .offset(y: thumbOffset)
                    Spacer()
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { gesture in
                        let raw = 1 - min(max((gesture.location.y - thumbSize / 2) / availableHeight, 0), 1)
                        let nextValue = range.lowerBound + Float(raw) * (range.upperBound - range.lowerBound)
                        value = stepped(clamped(nextValue), step: step)
                    }
            )
        }
    }

    private func percentage(for value: Float) -> Float {
        let width = range.upperBound - range.lowerBound
        guard width > 0 else { return 0 }
        return min(max((value - range.lowerBound) / width, 0), 1)
    }

    private func clamped(_ value: Float) -> Float {
        min(max(value, range.lowerBound), range.upperBound)
    }

    private func stepped(_ value: Float, step: Float) -> Float {
        guard step > 0 else { return value }
        return value - value.truncatingRemainder(dividingBy: step)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
