//
//  MultipleCaptureDeviceProperty.swift
//  ArtificeLens
//
//

import Foundation
import UVC

final class MultipleCaptureDeviceProperty: ObservableObject {
    private let control: UVCMultipleIntControl

    @Published private var intervalValue1: Float
    @Published private var intervalValue2: Float

    var sliderValue1: Float {
        get {
            return Float(control.current1)
        }
        set {
            let clampedValue = clamped(newValue, minimum1...maximum1)
            if sliderValue1 != clampedValue {
                control.current1 = Int(clampedValue)
                intervalValue1 = Float(control.current1)
            }
        }
    }

    var sliderValue2: Float {
        get {
            return Float(control.current2)
        }
        set {
            let clampedValue = clamped(newValue, minimum2...maximum2)
            if sliderValue2 != clampedValue {
                control.current2 = Int(clampedValue)
                intervalValue2 = Float(control.current2)
            }
        }
    }

    let isCapable: Bool
    let minimum1: Float
    let minimum2: Float
    let maximum1: Float
    let maximum2: Float
    let resolution1: Float
    let resolution2: Float
    let defaultValue1: Float
    let defaultValue2: Float

    init(_ control: UVCMultipleIntControl) {
        self.control = control
        isCapable = control.isCapable
        minimum1 = Float(control.minimum1)
        minimum2 = Float(control.minimum2)
        maximum1 = Float(control.maximum1)
        maximum2 = Float(control.maximum2)
        resolution1 = max(Float(control.resolution1), 1)
        resolution2 = max(Float(control.resolution2), 1)
        defaultValue1 = Float(control.defaultValue1)
        defaultValue2 = Float(control.defaultValue2)
        intervalValue1 = Float(control.defaultValue1)
        intervalValue2 = Float(control.defaultValue2)
        sliderValue1 = Float(control.current1)
        sliderValue2 = Float(control.current2)
    }

    func reset() {
        sliderValue1 = Float(control.defaultValue1)
        sliderValue2 = Float(control.defaultValue2)
    }

    func write() {
        sliderValue1 = Float(control.current1)
        sliderValue2 = Float(control.current2)
    }

    private func clamped(_ value: Float, _ range: ClosedRange<Float>) -> Float {
        min(max(value, range.lowerBound), range.upperBound)
    }
}
