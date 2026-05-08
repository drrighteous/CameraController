//
//  CaptureDevice.swift
//  ArtificeLens
//
//

import Foundation
import AVFoundation
import Combine
import UVC

final class CaptureDevice: Hashable, ObservableObject {
    let name: String
    let avDevice: AVCaptureDevice?
    let uvcDevice: UVCDevice?
    var controller: DeviceController?

    init(avDevice: AVCaptureDevice) {
        self.avDevice = avDevice
        self.name = avDevice.localizedName
        self.uvcDevice = try? UVCDevice(device: avDevice)
        self.controller = DeviceController(properties: uvcDevice?.properties)
    }

    static func == (lhs: CaptureDevice, rhs: CaptureDevice) -> Bool {
        return lhs.avDevice == rhs.avDevice
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(avDevice)
    }

    func isConfigurable() -> Bool {
        return uvcDevice != nil
    }

    func isDefaultDevice() -> Bool {
        return false
    }

    func readValuesFromDevice() {
        guard let controller = controller else {
            return
        }

        Task {
            controller.exposureTime.update()
            controller.irisAbsolute.update()
            controller.gamma.update()
            controller.whiteBalance.update()
            controller.focusAbsolute.update()
        }
    }

    func writeValuesToDevice() {
        guard let controller = controller else {
            return
        }

        Task {
            controller.writeValues()
        }
    }

    func diagnosticsReport() -> CameraDiagnosticsReport {
        CameraDiagnosticsReport(deviceName: name,
                                uniqueID: avDevice?.uniqueID,
                                modelID: avDevice?.modelID,
                                cameraTerminalID: uvcDevice?.cameraTerminalID,
                                processingUnitID: uvcDevice?.processingUnitID,
                                activeFormat: avDevice.map(CameraFormatDiagnostic.init(device:)),
                                controls: uvcDevice?.properties.diagnosticReports() ?? [])
    }
}

struct CameraDiagnosticsReport: Codable {
    let generatedAt: Date
    let deviceName: String
    let uniqueID: String?
    let modelID: String?
    let cameraTerminalID: Int?
    let processingUnitID: Int?
    let activeFormat: CameraFormatDiagnostic?
    let controls: [UVCControlDiagnostic]

    init(deviceName: String,
         uniqueID: String?,
         modelID: String?,
         cameraTerminalID: Int?,
         processingUnitID: Int?,
         activeFormat: CameraFormatDiagnostic?,
         controls: [UVCControlDiagnostic]) {
        self.generatedAt = Date()
        self.deviceName = deviceName
        self.uniqueID = uniqueID
        self.modelID = modelID
        self.cameraTerminalID = cameraTerminalID
        self.processingUnitID = processingUnitID
        self.activeFormat = activeFormat
        self.controls = controls
    }
}

struct CameraFormatDiagnostic: Codable {
    let width: Int32
    let height: Int32
    let mediaSubType: String
    let activeMinFrameRate: Double?
    let activeMaxFrameRate: Double?
    let supportedFrameRateRanges: [FrameRateRangeDiagnostic]

    init(device: AVCaptureDevice) {
        let format = device.activeFormat
        let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
        width = dimensions.width
        height = dimensions.height
        mediaSubType = Self.fourCC(CMFormatDescriptionGetMediaSubType(format.formatDescription))
        activeMinFrameRate = Self.frameRate(for: device.activeVideoMaxFrameDuration)
        activeMaxFrameRate = Self.frameRate(for: device.activeVideoMinFrameDuration)
        supportedFrameRateRanges = format.videoSupportedFrameRateRanges.map(FrameRateRangeDiagnostic.init(range:))
    }

    private static func frameRate(for duration: CMTime) -> Double? {
        guard duration.seconds.isFinite, duration.seconds > 0 else {
            return nil
        }

        return 1 / duration.seconds
    }

    private static func fourCC(_ code: FourCharCode) -> String {
        let bytes: [UInt8] = [
            UInt8((code >> 24) & 0xFF),
            UInt8((code >> 16) & 0xFF),
            UInt8((code >> 8) & 0xFF),
            UInt8(code & 0xFF)
        ]
        return String(bytes: bytes, encoding: .macOSRoman) ?? "\(code)"
    }
}

struct FrameRateRangeDiagnostic: Codable {
    let minFrameRate: Double
    let maxFrameRate: Double

    init(range: AVFrameRateRange) {
        minFrameRate = range.minFrameRate
        maxFrameRate = range.maxFrameRate
    }
}
