//
//  UVCDeviceProperties.swift
//  ArtificeLens
//
//

import Foundation

public final class UVCDeviceProperties {
    public let scanningMode: UVCBoolControl
    public let exposureMode: UVCBitmapControl
    public let exposurePriority: UVCBoolControl
    public let exposureTime: UVCIntControl
    public let focusAbsolute: UVCIntControl
    public let focusAuto: UVCBoolControl
    public let irisAbsolute: UVCIntControl
    public let zoomAbsolute: UVCIntControl
    public let panTiltAbsolute: UVCMultipleIntControl
    public let rollAbsolute: UVCIntControl

    public let backlightCompensation: UVCIntControl
    public let brightness: UVCIntControl
    public let contrast: UVCIntControl
    public let contrastAuto: UVCBoolControl
    public let gain: UVCIntControl
    public let powerLineFrequency: UVCIntControl
    public let hue: UVCIntControl
    public let hueAuto: UVCBoolControl
    public let saturation: UVCIntControl
    public let sharpness: UVCIntControl
    public let gamma: UVCIntControl
    public let whiteBalance: UVCIntControl
    public let whiteBalanceAuto: UVCBoolControl

    init(_ device: USBDevice) {
        let interface = device.interface
        let camerTerminalId = device.descriptor.cameraTerminalID
        let processingUnitId = device.descriptor.processingUnitID
        let interfaceId = device.descriptor.interfaceID

        scanningMode = UVCBoolControl(interface, 1, UVCCameraTerminal.scanningMode, camerTerminalId, interfaceId,
                                      metadata: Self.cameraTerminalMetadata(key: "scanningMode",
                                                                            name: "Scanning Mode",
                                                                            selector: UVCCameraTerminal.scanningMode,
                                                                            size: 1))
        exposureMode = UVCBitmapControl(interface, 1, UVCCameraTerminal.aeMode, camerTerminalId, interfaceId,
                                        metadata: Self.cameraTerminalMetadata(key: "exposureMode",
                                                                              name: "Auto Exposure Mode",
                                                                              selector: UVCCameraTerminal.aeMode,
                                                                              size: 1))
        // Keep this surface limited to standard UVC controls. Vendor extension units
        // stay out of the normal app UI until each selector has been validated.
        exposurePriority = UVCBoolControl(interface, 1, UVCCameraTerminal.aePriority, camerTerminalId, interfaceId,
                                          metadata: Self.cameraTerminalMetadata(key: "exposurePriority",
                                                                                name: "Auto Exposure Priority",
                                                                                selector: UVCCameraTerminal.aePriority,
                                                                                size: 1,
                                                                                hasDefault: false))
        exposureTime = UVCIntControl(interface, 4, UVCCameraTerminal.exposureTimeAbsolute, camerTerminalId, interfaceId,
                                     metadata: Self.numericCameraTerminalMetadata(key: "exposureTime",
                                                                                  name: "Exposure Time Absolute",
                                                                                  selector: UVCCameraTerminal.exposureTimeAbsolute,
                                                                                  size: 4))
        focusAbsolute = UVCIntControl(interface, 2, UVCCameraTerminal.focusAbsolute, camerTerminalId, interfaceId,
                                      metadata: Self.numericCameraTerminalMetadata(key: "focus",
                                                                                   name: "Focus Absolute",
                                                                                   selector: UVCCameraTerminal.focusAbsolute,
                                                                                   size: 2))
        focusAuto = UVCBoolControl(interface, 1, UVCCameraTerminal.focusAuto, camerTerminalId, interfaceId,
                                   metadata: Self.cameraTerminalMetadata(key: "focusAuto",
                                                                         name: "Focus Auto",
                                                                         selector: UVCCameraTerminal.focusAuto,
                                                                         size: 1))
        irisAbsolute = UVCIntControl(interface, 2, UVCCameraTerminal.irisAbsolute, camerTerminalId, interfaceId,
                                     metadata: Self.numericCameraTerminalMetadata(key: "iris",
                                                                                  name: "Iris Absolute",
                                                                                  selector: UVCCameraTerminal.irisAbsolute,
                                                                                  size: 2))
        zoomAbsolute = UVCIntControl(interface, 2, UVCCameraTerminal.zoomAbsolute, camerTerminalId, interfaceId,
                                     metadata: Self.numericCameraTerminalMetadata(key: "zoom",
                                                                                  name: "Zoom Absolute",
                                                                                  selector: UVCCameraTerminal.zoomAbsolute,
                                                                                  size: 2))
        panTiltAbsolute = UVCMultipleIntControl(interface, 8, UVCCameraTerminal.pantiltAbsolute,
                                                camerTerminalId, interfaceId,
                                                metadata: Self.numericCameraTerminalMetadata(key: "panTilt",
                                                                                             name: "Pan/Tilt Absolute",
                                                                                             selector: UVCCameraTerminal.pantiltAbsolute,
                                                                                             size: 8,
                                                                                             isSigned: true))
        rollAbsolute = UVCIntControl(interface, 2, UVCCameraTerminal.rollAbsolute, camerTerminalId, interfaceId,
                                     metadata: Self.numericCameraTerminalMetadata(key: "roll",
                                                                                  name: "Roll Absolute",
                                                                                  selector: UVCCameraTerminal.rollAbsolute,
                                                                                  size: 2,
                                                                                  isSigned: true))

        backlightCompensation = UVCIntControl(interface, 2, UVCProcessingUnit.backlightCompensation,
                                              processingUnitId, interfaceId,
                                              metadata: Self.numericProcessingMetadata(key: "backlightCompensation",
                                                                                       name: "Backlight Compensation",
                                                                                       selector: UVCProcessingUnit.backlightCompensation,
                                                                                       size: 2))
        brightness = UVCIntControl(interface, 2, UVCProcessingUnit.brightness, processingUnitId, interfaceId,
                                   metadata: Self.numericProcessingMetadata(key: "brightness",
                                                                            name: "Brightness",
                                                                            selector: UVCProcessingUnit.brightness,
                                                                            size: 2,
                                                                            isSigned: true))
        contrast = UVCIntControl(interface, 2, UVCProcessingUnit.contrast, processingUnitId, interfaceId,
                                 metadata: Self.numericProcessingMetadata(key: "contrast",
                                                                          name: "Contrast",
                                                                          selector: UVCProcessingUnit.contrast,
                                                                          size: 2))
        contrastAuto = UVCBoolControl(interface, 1, UVCProcessingUnit.contrastAuto, processingUnitId, interfaceId,
                                      metadata: Self.processingMetadata(key: "contrastAuto",
                                                                        name: "Contrast Auto",
                                                                        selector: UVCProcessingUnit.contrastAuto,
                                                                        size: 1))
        gain = UVCIntControl(interface, 2, UVCProcessingUnit.gain, processingUnitId, interfaceId,
                             metadata: Self.numericProcessingMetadata(key: "gain",
                                                                      name: "Gain",
                                                                      selector: UVCProcessingUnit.gain,
                                                                      size: 2))
        powerLineFrequency = UVCIntControl(interface, 2, UVCProcessingUnit.powerLineFrequency,
                                           processingUnitId, interfaceId,
                                           metadata: Self.numericProcessingMetadata(key: "powerLineFrequency",
                                                                                    name: "Power Line Frequency",
                                                                                    selector: UVCProcessingUnit.powerLineFrequency,
                                                                                    size: 2))
        hue = UVCIntControl(interface, 2, UVCProcessingUnit.hue, processingUnitId, interfaceId,
                            metadata: Self.numericProcessingMetadata(key: "hue",
                                                                     name: "Hue",
                                                                     selector: UVCProcessingUnit.hue,
                                                                     size: 2,
                                                                     isSigned: true))
        hueAuto = UVCBoolControl(interface, 1, UVCProcessingUnit.hueAuto, processingUnitId, interfaceId,
                                 metadata: Self.processingMetadata(key: "hueAuto",
                                                                   name: "Hue Auto",
                                                                   selector: UVCProcessingUnit.hueAuto,
                                                                   size: 1))
        saturation = UVCIntControl(interface, 2, UVCProcessingUnit.saturation, processingUnitId, interfaceId,
                                   metadata: Self.numericProcessingMetadata(key: "saturation",
                                                                            name: "Saturation",
                                                                            selector: UVCProcessingUnit.saturation,
                                                                            size: 2))
        sharpness = UVCIntControl(interface, 2, UVCProcessingUnit.sharpness, processingUnitId, interfaceId,
                                  metadata: Self.numericProcessingMetadata(key: "sharpness",
                                                                           name: "Sharpness",
                                                                           selector: UVCProcessingUnit.sharpness,
                                                                           size: 2))
        gamma = UVCIntControl(interface, 2, UVCProcessingUnit.gamma, processingUnitId, interfaceId,
                              metadata: Self.numericProcessingMetadata(key: "gamma",
                                                                       name: "Gamma",
                                                                       selector: UVCProcessingUnit.gamma,
                                                                       size: 2))
        whiteBalance = UVCIntControl(interface, 2, UVCProcessingUnit.whiteBalanceTemperature,
                                     processingUnitId, interfaceId,
                                     metadata: Self.numericProcessingMetadata(key: "whiteBalance",
                                                                              name: "White Balance Temperature",
                                                                              selector: UVCProcessingUnit.whiteBalanceTemperature,
                                                                              size: 2))
        whiteBalanceAuto = UVCBoolControl(interface, 1, UVCProcessingUnit.whiteBalanceTemperatureAuto,
                                          processingUnitId, interfaceId,
                                          metadata: Self.processingMetadata(key: "whiteBalanceAuto",
                                                                            name: "White Balance Temperature Auto",
                                                                            selector: UVCProcessingUnit.whiteBalanceTemperatureAuto,
                                                                            size: 1))
    }

    public var allControls: [UVCControl] {
        [
            scanningMode,
            exposureMode,
            exposurePriority,
            exposureTime,
            focusAbsolute,
            focusAuto,
            irisAbsolute,
            zoomAbsolute,
            panTiltAbsolute,
            rollAbsolute,
            backlightCompensation,
            brightness,
            contrast,
            contrastAuto,
            gain,
            powerLineFrequency,
            hue,
            hueAuto,
            saturation,
            sharpness,
            gamma,
            whiteBalance,
            whiteBalanceAuto
        ]
    }

    public func diagnosticReports() -> [UVCControlDiagnostic] {
        allControls.map { $0.diagnosticReport() }
    }

    private static func numericCameraTerminalMetadata(key: String,
                                                      name: String,
                                                      selector: Selector,
                                                      size: Int,
                                                      isSigned: Bool = false) -> UVCControlMetadata {
        cameraTerminalMetadata(key: key,
                               name: name,
                               selector: selector,
                               size: size,
                               isSigned: isSigned,
                               hasMinimum: true,
                               hasMaximum: true,
                               hasDefault: true,
                               hasResolution: true)
    }

    private static func numericProcessingMetadata(key: String,
                                                  name: String,
                                                  selector: Selector,
                                                  size: Int,
                                                  isSigned: Bool = false) -> UVCControlMetadata {
        processingMetadata(key: key,
                           name: name,
                           selector: selector,
                           size: size,
                           isSigned: isSigned,
                           hasMinimum: true,
                           hasMaximum: true,
                           hasDefault: true,
                           hasResolution: true)
    }

    private static func cameraTerminalMetadata(key: String,
                                               name: String,
                                               selector: Selector,
                                               size: Int,
                                               isSigned: Bool = false,
                                               hasMinimum: Bool = false,
                                               hasMaximum: Bool = false,
                                               hasDefault: Bool = true,
                                               hasResolution: Bool = false) -> UVCControlMetadata {
        UVCControlMetadata(key: key,
                           name: name,
                           unit: .cameraTerminal,
                           selector: selector,
                           size: size,
                           isSigned: isSigned,
                           hasMinimum: hasMinimum,
                           hasMaximum: hasMaximum,
                           hasDefault: hasDefault,
                           hasResolution: hasResolution)
    }

    private static func processingMetadata(key: String,
                                           name: String,
                                           selector: Selector,
                                           size: Int,
                                           isSigned: Bool = false,
                                           hasMinimum: Bool = false,
                                           hasMaximum: Bool = false,
                                           hasDefault: Bool = true,
                                           hasResolution: Bool = false) -> UVCControlMetadata {
        UVCControlMetadata(key: key,
                           name: name,
                           unit: .processingUnit,
                           selector: selector,
                           size: size,
                           isSigned: isSigned,
                           hasMinimum: hasMinimum,
                           hasMaximum: hasMaximum,
                           hasDefault: hasDefault,
                           hasResolution: hasResolution)
    }
}
