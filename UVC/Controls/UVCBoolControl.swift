//
//  UVCBoolControl.swift
//  ArtificeLens
//
//

import Foundation

public final class UVCBoolControl: UVCControl {
    public var defaultValue: Bool = false

    public var isEnabled: Bool {
        get {
            return _isEnabled
        }
        set {
            let value = newValue ? 1 : 0
            if setData(value: value, length: uvcSize) {
                _isEnabled = newValue
            }
        }
    }

    private var _isEnabled = false

    override init(_ interface: USBInterfacePointer, _ uvcSize: Int,
                  _ uvcSelector: Selector, _ uvcUnit: Int, _ uvcInterface: Int,
                  metadata: UVCControlMetadata? = nil) {
        super.init(interface, uvcSize, uvcSelector, uvcUnit, uvcInterface, metadata: metadata)
        configure()
    }

    private func configure() {
        updateIsCapable()

        if isCapable {
            updateEnabled()
            updateDefault()
        }
    }

    func updateEnabled() {
        _isEnabled = getDataFor(type: .getCurrent, length: uvcSize) != 0
    }

    func updateDefault() {
        guard metadata.hasDefault else {
            defaultValue = false
            return
        }

        defaultValue = getDataFor(type: .getDefault, length: uvcSize) != 0
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
                             current: _isEnabled ? 1 : 0,
                             minimum: nil,
                             maximum: nil,
                             defaultValue: metadata.hasDefault ? (defaultValue ? 1 : 0) : nil,
                             resolution: nil)
    }
}
