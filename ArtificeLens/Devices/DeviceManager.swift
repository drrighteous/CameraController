//
//  DeviceManager.swift
//  ArtificeLens
//
//

import Combine
import Foundation
import AVFoundation

final class DevicesManager: ObservableObject {
    static let shared = DevicesManager()

    private let deviceMonitor = DeviceMonitor()

    @Published var devices: [CaptureDevice] = []

    @Published var selectedDevice: CaptureDevice? {
        willSet {
            if newValue != nil && selectedDevice != newValue {
                UserSettings.shared.lastSelectedDevice = newValue?.avDevice?.uniqueID
            }
            deviceMonitor.updateDevice(newValue)
        }
    }

    private init() {
        refreshDevices(postNotification: false)
    }

    func refreshDevices() {
        refreshDevices(postNotification: true)
    }

    private func refreshDevices(postNotification: Bool) {
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: Self.cameraDeviceTypes,
                                                                mediaType: nil,
                                                                position: .unspecified)
        let selectedUniqueID = selectedDevice?.avDevice?.uniqueID ?? UserSettings.shared.lastSelectedDevice

        devices = session.devices.map({ (device) -> CaptureDevice in
            CaptureDevice(avDevice: device)
        })

        if let deviceId = selectedUniqueID {
            selectedDevice = devices.first { (device) -> Bool in
                device.avDevice?.uniqueID == deviceId
            }
        }

        if selectedDevice == nil {
            selectedDevice = devices.first
        }

        if postNotification {
            NotificationCenter.default.post(name: .devicesUpdated, object: nil)
        }
    }

    private static var cameraDeviceTypes: [AVCaptureDevice.DeviceType] {
        if #available(macOS 14.0, *) {
            return [.external, .builtInWideAngleCamera]
        } else {
            return [.externalUnknown, .builtInWideAngleCamera]
        }
    }

    func startMonitoring() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(deviceAdded(notif:)),
                                               name: NSNotification.Name.AVCaptureDeviceWasConnected,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(deviceRemoved(notif:)),
                                               name: NSNotification.Name.AVCaptureDeviceWasDisconnected,
                                               object: nil)
    }

    func stopMonitoring() {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.AVCaptureDeviceWasConnected,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.AVCaptureDeviceWasDisconnected,
                                                  object: nil)
    }

    @objc
    func deviceAdded(notif: NSNotification) {
        guard let device = notif.object as? AVCaptureDevice else {
            return
        }

        guard !devices.contains(where: { $0.avDevice?.uniqueID == device.uniqueID }) else {
            return
        }

        let captureDevice = CaptureDevice(avDevice: device)
        devices.append(captureDevice)
        if selectedDevice == nil {
            selectedDevice = captureDevice
        }
        NotificationCenter.default.post(name: .devicesUpdated, object: nil)
    }

    @objc
    func deviceRemoved(notif: NSNotification) {
        guard let device = notif.object as? AVCaptureDevice else {
            return
        }

        guard let index = devices.firstIndex(where: { captureDevice in
            captureDevice.avDevice?.uniqueID == device.uniqueID
        }) else {
            return
        }

        devices.remove(at: index)

        if device.uniqueID == selectedDevice?.avDevice?.uniqueID {
            selectedDevice = nil
        }
        NotificationCenter.default.post(name: .devicesUpdated, object: nil)
    }
}
