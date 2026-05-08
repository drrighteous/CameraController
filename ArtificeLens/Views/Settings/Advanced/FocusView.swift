//
//  FocusView.swift
//  ArtificeLens
//
//

import SwiftUI

struct FocusView: View {
    @ObservedObject var focusAuto: BoolCaptureDeviceProperty
    @ObservedObject var focusAbsolute: NumberCaptureDeviceProperty

    init(controller: DeviceController) {
        self.focusAuto = controller.focusAuto
        self.focusAbsolute = controller.focusAbsolute
    }

    var body: some View {
        GenericControl(value: $focusAbsolute.sliderValue,
                       step: focusAbsolute.resolution,
                       range: focusAbsolute.minimum...focusAbsolute.maximum,
                       title: "Focus",
                       imageName: "camera.aperture",
                       auto: $focusAuto.isEnabled,
                       help: "Adjusts lens focus distance. Auto lets the camera refocus on its own.")
    }
}
