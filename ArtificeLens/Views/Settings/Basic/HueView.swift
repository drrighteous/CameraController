//
//  HueView.swift
//  ArtificeLens
//
//

import SwiftUI

struct HueView: View {
    @ObservedObject var hueAuto: BoolCaptureDeviceProperty
    @ObservedObject var hue: NumberCaptureDeviceProperty

    init(controller: DeviceController) {
        self.hueAuto = controller.hueAuto
        self.hue = controller.hue
    }

    var body: some View {
        GenericControl(value: $hue.sliderValue,
                       step: hue.resolution,
                       range: hue.minimum...hue.maximum,
                       title: "Hue",
                       imageName: "hue",
                       auto: $hueAuto.isEnabled,
                       help: "Shifts the color hue when the camera exposes this UVC control.")
    }
}
