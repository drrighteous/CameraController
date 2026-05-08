//
//  CameraPrreviewInternal.swift
//  ArtificeLens
//
//

import Foundation
import Cocoa
import AVFoundation

final class CameraPreviewInternal: NSView {
    var captureDevice: AVCaptureDevice?
    private let captureSession: AVCaptureSession
    private let previewLayer: AVCaptureVideoPreviewLayer
    private let photoOutput: AVCapturePhotoOutput
    private let sessionQueue = DispatchQueue(label: "com.drrighteous.ArtificeLens.camera-session")
    private var captureInput: AVCaptureInput?
    private var photoDelegates: [UUID: PreviewPhotoCaptureDelegate] = [:]

    init(frame frameRect: NSRect, device: AVCaptureDevice?) {
        captureDevice = device
        captureSession = AVCaptureSession()
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        photoOutput = AVCapturePhotoOutput()

        super.init(frame: frameRect)

        wantsLayer = true
        setupPreviewLayer()

        configureAndStart(device)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(windowClosed),
                                               name: .windowClose,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(windowOpen),
                                               name: .windowOpen,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(captureStillRequested(_:)),
                                               name: .captureStillRequested,
                                               object: nil)
    }

    private func setupPreviewLayer() {
        previewLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: UserSettings.shared.cameraPreviewSize.getWidth(),
            height: UserSettings.shared.cameraPreviewSize.getHeight()
        )
        previewLayer.videoGravity = .resizeAspect
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func layout() {
        super.layout()
        previewLayer.frame = bounds
        if previewLayer.superlayer == nil {
            layer?.addSublayer(previewLayer)
        }
    }

    func stopRunning() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }

    func updateCamera(_ cam: AVCaptureDevice?) {
        if captureDevice != cam {
            sessionQueue.async { [weak self] in
                guard let self else { return }

                if self.captureSession.isRunning {
                    self.captureSession.stopRunning()
                }

                self.configureDevice(cam)
                self.startRunning()
            }
        }
    }

    private func configureAndStart(_ device: AVCaptureDevice?) {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.configureDevice(device)
            self.startRunning()
        }
    }

    private func startRunning() {
        do {
            try captureDevice?.lockForConfiguration()
            defer {
                captureDevice?.unlockForConfiguration()
            }
            captureSession.startRunning()
        } catch {
            NSLog("Unable to start camera preview session: \(error.localizedDescription)")
        }
    }

    private func configureDevice(_ aDevice: AVCaptureDevice?) {
        captureSession.beginConfiguration()
        defer {
            captureSession.commitConfiguration()
        }

        if let input = captureInput {
            captureSession.removeInput(input)
            captureInput = nil
        }

        guard let device = aDevice else {
            captureDevice = aDevice
            return
        }

        do {
            captureInput = try AVCaptureDeviceInput(device: device)
        } catch {
            return
        }

        if let input = captureInput,
            captureSession.canAddInput(input) {
            captureSession.addInput(input)
        } else {
            return
        }

        if !captureSession.outputs.contains(where: { $0 === photoOutput }),
           captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        captureDevice = device
    }

    @objc
    func windowClosed() {
        stopRunning()
    }

    @objc
    func windowOpen() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if !self.captureSession.isRunning {
                self.startRunning()
            }
        }
    }

    @objc
    func captureStillRequested(_ notification: Notification) {
        guard let url = notification.userInfo?["url"] as? URL else {
            return
        }

        captureStill(to: url)
    }

    private func captureStill(to url: URL) {
        sessionQueue.async { [weak self] in
            guard let self,
                  self.captureSession.isRunning,
                  self.captureSession.outputs.contains(where: { $0 === self.photoOutput }) else {
                return
            }

            let id = UUID()
            let delegate = PreviewPhotoCaptureDelegate(url: url) { [weak self] in
                self?.sessionQueue.async {
                    self?.photoDelegates[id] = nil
                }
            }

            self.photoDelegates[id] = delegate
            self.photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: delegate)
        }
    }
}

private final class PreviewPhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let url: URL
    private let completion: () -> Void

    init(url: URL, completion: @escaping () -> Void) {
        self.url = url
        self.completion = completion
    }

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        defer {
            completion()
        }

        if let error {
            NSLog("Unable to capture still image: \(error.localizedDescription)")
            postCaptureStatus("Capture failed: \(error.localizedDescription)", success: false)
            return
        }

        guard let data = photo.fileDataRepresentation() else {
            NSLog("Unable to capture still image: no photo data returned")
            postCaptureStatus("Capture failed: no photo data returned", success: false)
            return
        }

        let accessed = url.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            try data.write(to: url, options: .atomic)
            postCaptureStatus("Saved \(url.lastPathComponent)", success: true)
        } catch {
            NSLog("Unable to save still image: \(error.localizedDescription)")
            postCaptureStatus("Save failed: \(error.localizedDescription)", success: false)
        }
    }

    private func postCaptureStatus(_ message: String, success: Bool) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .captureStillCompleted,
                                            object: nil,
                                            userInfo: ["message": message, "success": success])
        }
    }
}

extension CameraPreviewInternal {
    override public func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)

        window?.performDrag(with: event)
        NSCursor.contextualMenu.set()
    }

    override public func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)

        NSCursor.contextualMenu.set()
    }

    override public func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)

        NSCursor.arrow.set()
    }

    override func mouseMoved(with event: NSEvent) {
        NSCursor.contextualMenu.set()
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        for trackingArea in self.trackingAreas {
            self.removeTrackingArea(trackingArea)
        }

        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways, .mouseMoved]
        let trackingArea = NSTrackingArea(rect: self.bounds, options: options, owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
    }
}
