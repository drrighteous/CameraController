//
//  WhiteBalanceView.swift
//  ArtificeLens
//
//

import SwiftUI

struct WhiteBalanceView: View {
    @ObservedObject var whiteBalanceAuto: BoolCaptureDeviceProperty
    @ObservedObject var whiteBalance: NumberCaptureDeviceProperty

    init(controller: DeviceController) {
        self.whiteBalanceAuto = controller.whiteBalanceAuto
        self.whiteBalance = controller.whiteBalance
    }

    var body: some View {
        GenericControl(value: $whiteBalance.sliderValue,
                       step: whiteBalance.resolution,
                       range: whiteBalance.minimum...whiteBalance.maximum,
                       title: "White Balance",
                       imageName: "slider.horizontal.3",
                       auto: $whiteBalanceAuto.isEnabled,
                       help: "Adjusts color temperature. Auto lets the camera choose the white balance.")
    }
}
