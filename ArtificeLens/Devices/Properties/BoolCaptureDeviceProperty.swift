//
//  BoolCaptureDeviceProperty.swift
//  ArtificeLens
//
//

import Foundation
import UVC

final class BoolCaptureDeviceProperty: ObservableObject {
    private let control: UVCBoolControl

    let isCapable: Bool

    @Published private var internalValue: Bool

    var isEnabled: Bool {
        get {
            return control.isEnabled
        }
        set {
            if newValue != isEnabled {
                control.isEnabled = newValue
                internalValue = control.isEnabled
            }
        }
    }

    init(_ control: UVCBoolControl) {
        self.control = control
        isCapable = control.isCapable
        internalValue = control.isEnabled
        isEnabled = control.isEnabled
    }

    func reset() {
        isEnabled = control.defaultValue
    }

    func write() {
        isEnabled = control.isEnabled
    }
}
