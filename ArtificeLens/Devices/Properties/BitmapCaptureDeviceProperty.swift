//
//  BitmapCaptureDeviceProperty.swift
//  ArtificeLens
//
//

import Foundation
import UVC

final class BitmapCaptureDeviceProperty: ObservableObject {
    private let control: UVCBitmapControl

    let isCapable: Bool

    @Published private var internalValue: UVCBitmapControl.BitmapValue

    var selected: UVCBitmapControl.BitmapValue {
        get {
            return control.current
        }
        set {
            control.current = newValue
            internalValue = control.current
        }
    }

    init(_ control: UVCBitmapControl) {
        self.control = control
        internalValue = control.current
        isCapable = control.isCapable
        selected = control.current
    }

    func reset() {
        selected = control.defaultValue
    }

    func write() {
        selected = control.current
    }
}
