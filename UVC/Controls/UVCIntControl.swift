//
//  UVCIntControl.swift
//  ArtificeLens
//
//

import Foundation

public final class UVCIntControl: UVCControl {
    public var minimum: Int = 0
    public var maximum: Int = 0
    public var defaultValue: Int = 0
    public var resolution: Int = 0

    public var current: Int {
        get {
            return _current
        }
        set {
            let clampedValue = clamped(newValue)
            if setData(value: clampedValue, length: uvcSize) {
                _current = clampedValue
            }
        }
    }

    private var _current: Int = 0

    override init(_ interface: USBInterfacePointer, _ uvcSize: Int,
                  _ uvcSelector: Selector, _ uvcUnit: Int, _ uvcInterface: Int,
                  metadata: UVCControlMetadata? = nil) {
        super.init(interface, uvcSize, uvcSelector, uvcUnit, uvcInterface, metadata: metadata)
        configure()
    }

    private func configure() {
        updateIsCapable()

        if isCapable {
            updateMinimum()
            updateDefault()
            updateMaximum()
            updateResolution()
            _current = getCurrent()

            if minimum > maximum {
                minimum = 0
            }

            isCapable = minimum != maximum
        }
    }

    public func getCurrent() -> Int {
        return getDataFor(type: .getCurrent, length: uvcSize)
    }

    func updateMinimum() {
        minimum = getDataFor(type: .getMinimum, length: uvcSize)
    }

    func updateMaximum() {
        maximum = getDataFor(type: .getMaximum, length: uvcSize)
    }

    func updateDefault() {
        defaultValue = getDataFor(type: .getDefault, length: uvcSize)
    }

    func updateResolution() {
        resolution = getDataFor(type: .getRessolution, length: uvcSize)
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
                             current: _current,
                             minimum: metadata.hasMinimum ? minimum : nil,
                             maximum: metadata.hasMaximum ? maximum : nil,
                             defaultValue: metadata.hasDefault ? defaultValue : nil,
                             resolution: metadata.hasResolution ? resolution : nil)
    }

    private func clamped(_ value: Int) -> Int {
        guard isCapable, minimum <= maximum else {
            return value
        }

        return min(max(value, minimum), maximum)
    }
}
