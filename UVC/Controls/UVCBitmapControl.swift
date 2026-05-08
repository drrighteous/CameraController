//
//  UVCBitmapControl.swift
//  ArtificeLens
//
//

import Foundation

public final class UVCBitmapControl: UVCControl {
    public enum BitmapValue: Int, CaseIterable, Identifiable {
        case manual = 1
        case auto = 2
        case shutterPriority = 4
        case aperturePriority = 8

        public var id: Int {
            rawValue
        }

        public var title: String {
            switch self {
            case .manual:
                return "Manual"
            case .auto:
                return "Auto"
            case .shutterPriority:
                return "Shutter"
            case .aperturePriority:
                return "Iris"
            }
        }

        public var helpText: String {
            switch self {
            case .manual:
                return "Manual exposure and manual iris."
            case .auto:
                return "Camera controls exposure and iris automatically."
            case .shutterPriority:
                return "Manual exposure time with automatic iris."
            case .aperturePriority:
                return "Automatic exposure with manual iris."
            }
        }
    }

    public var defaultValue: BitmapValue = .manual

    public var current: BitmapValue {
        get {
            return internalCurrent
        }
        set {
            if setData(value: newValue.rawValue, length: uvcSize) {
                internalCurrent = newValue
            }
        }
    }

    var internalCurrent: BitmapValue = .manual

    override init(_ interface: USBInterfacePointer, _ uvcSize: Int,
                  _ uvcSelector: Selector, _ uvcUnit: Int, _ uvcInterface: Int,
                  metadata: UVCControlMetadata? = nil) {
        super.init(interface, uvcSize, uvcSelector, uvcUnit, uvcInterface, metadata: metadata)
        configure()
    }

    private func configure() {
        updateIsCapable()

        if isCapable {
            updateCurrent()
            updateDefault()
        }
    }

    func updateCurrent() {
        let value = getDataFor(type: .getCurrent, length: 1)

        if let parsed = BitmapValue(rawValue: value) {
            internalCurrent = parsed
        } else {
            isCapable = false
        }
    }

    func updateDefault() {
        let value = getDataFor(type: .getDefault, length: 1)

        if let parsed = BitmapValue(rawValue: value) {
            defaultValue = parsed
        } else {
            isCapable = false
        }
    }

    public override func diagnosticReport() -> UVCControlDiagnostic {
        UVCControlDiagnostic(key: metadata.key,
                             name: metadata.name,
                             unit: metadata.unit.rawValue,
                             selector: metadata.selector,
                             size: metadata.size,
                             signed: metadata.isSigned,
                             relative: metadata.isRelative,
                             supported: isCapable,
                             canGet: capabilities.canGet,
                             canSet: capabilities.canSet,
                             rawInfo: capabilities.rawValue,
                             lastError: lastErrorDescription,
                             current: internalCurrent.rawValue,
                             minimum: nil,
                             maximum: nil,
                             defaultValue: metadata.hasDefault ? defaultValue.rawValue : nil,
                             resolution: nil)
    }
}
