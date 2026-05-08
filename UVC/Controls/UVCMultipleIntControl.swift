//
//  UVCMultipleIntControl.swift
//  ArtificeLens
//
//

import Foundation

public final class UVCMultipleIntControl: UVCControl {
    public var minimum1: Int = 0
    public var minimum2: Int = 0
    public var maximum1: Int = 0
    public var maximum2: Int = 0
    public var defaultValue1: Int = 0
    public var defaultValue2: Int = 0
    public var resolution1: Int = 0
    public var resolution2: Int = 0

    public var current1: Int {
        get {
            return _current1
        }
        set {
            let clampedValue = min(max(newValue, minimum1), maximum1)
            if set1(clampedValue) {
                _current1 = clampedValue
            }
        }
    }

    public var current2: Int {
        get {
            return _current2
        }
        set {
            let clampedValue = min(max(newValue, minimum2), maximum2)
            if set2(clampedValue) {
                _current2 = clampedValue
            }
        }
    }

    private var _current1: Int = 0
    private var _current2: Int = 0

    override init(_ interface: USBInterfacePointer, _ uvcSize: Int,
                  _ uvcSelector: Selector, _ uvcUnit: Int, _ uvcInterface: Int,
                  metadata: UVCControlMetadata? = nil) {
        super.init(interface, uvcSize, uvcSelector, uvcUnit, uvcInterface, metadata: metadata)
        configure()
    }

    private func set1(_ val1: Int) -> Bool {
        return setData(value: combinedValue(val1, _current2), length: uvcSize)
    }

    private func set2(_ val2: Int) -> Bool {
        return setData(value: combinedValue(_current1, val2), length: uvcSize)
    }

    private func configure() {
        updateIsCapable()

        if isCapable {
            updateMinimum()
            updateDefault()
            updateMaximum()
            updateCurrent()
            updateResolution()
        }
    }

    func splitValue(_ value: Int) -> (Int, Int) {
        let rawValue = UInt64(bitPattern: Int64(value))
        let value1 = Int(Int32(bitPattern: UInt32(rawValue & 0xFFFF_FFFF))) / 3600
        let value2 = Int(Int32(bitPattern: UInt32((rawValue >> 32) & 0xFFFF_FFFF))) / 3600

        return (value1, value2)
    }

    private func combinedValue(_ val1: Int, _ val2: Int) -> Int {
        let value1 = UInt64(UInt32(bitPattern: Int32(val1 * 3600)))
        let value2 = UInt64(UInt32(bitPattern: Int32(val2 * 3600))) << 32
        return Int(Int64(bitPattern: value1 | value2))
    }

    func updateCurrent() {
        let currentValue = getDataFor(type: .getCurrent, length: uvcSize)
        let splitted = splitValue(currentValue)
        _current1 = splitted.0
        _current2 = splitted.1
    }

    func updateMinimum() {
        let minimum = getDataFor(type: .getMinimum, length: uvcSize)
        let splitted = splitValue(minimum)
        minimum1 = splitted.0
        minimum2 = splitted.1
    }

    func updateMaximum() {
        let maximum = getDataFor(type: .getMaximum, length: uvcSize)
        let splitted = splitValue(maximum)
        maximum1 = splitted.0
        maximum2 = splitted.1
    }

    func updateDefault() {
        let defaultValue = getDataFor(type: .getDefault, length: uvcSize)
        let splitted = splitValue(defaultValue)
        defaultValue1 = splitted.0
        defaultValue2 = splitted.1
    }

    func updateResolution() {
        let resolution = getDataFor(type: .getRessolution, length: uvcSize)
        let splitted = splitValue(resolution)
        resolution1 = splitted.0
        resolution2 = splitted.1
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
                             current: combinedValue(_current1, _current2),
                             minimum: metadata.hasMinimum ? combinedValue(minimum1, minimum2) : nil,
                             maximum: metadata.hasMaximum ? combinedValue(maximum1, maximum2) : nil,
                             defaultValue: metadata.hasDefault ? combinedValue(defaultValue1, defaultValue2) : nil,
                             resolution: metadata.hasResolution ? combinedValue(resolution1, resolution2) : nil)
    }
}
