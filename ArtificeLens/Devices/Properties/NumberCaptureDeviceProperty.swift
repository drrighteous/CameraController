//
//  IntCaptureDeviceProperty.swift
//  ArtificeLens
//
//

import Foundation
import Combine
import UVC

protocol SliderCapableProperty {
    var sliderValue: Float { get set }
    var isCapable: Bool { get }
    var minimum: Float { get }
    var maximum: Float { get }
    var resolution: Float { get }
    var defaultValue: Float { get }
}

final class NumberCaptureDeviceProperty: SliderCapableProperty, ObservableObject {
    private let control: UVCIntControl

    @Published private var internalValue: Float

    var sliderValue: Float {
        get {
            return Float(control.current)
        }
        set {
            let clampedValue = clamped(newValue)
            if sliderValue != clampedValue {
                control.current = Int(clampedValue)
                internalValue = Float(control.current)
            }
        }
    }

    let isCapable: Bool
    let minimum: Float
    var maximum: Float
    let resolution: Float
    let defaultValue: Float

    init(_ control: UVCIntControl) {
        self.control = control
        isCapable = control.isCapable
        internalValue = Float(control.defaultValue)
        minimum = Float(control.minimum)
        maximum = Float(control.maximum)
        resolution = max(Float(control.resolution), 1)
        defaultValue = Float(control.defaultValue)
        sliderValue = Float(control.current)
    }

    func reset() {
        sliderValue = Float(control.defaultValue)
    }

    func update() {
        let newValue = control.getCurrent()
        sliderValue = Float(newValue)
    }

    func write() {
        sliderValue = Float(control.current)
    }

    private func clamped(_ value: Float) -> Float {
        min(max(value, minimum), maximum)
    }
}
