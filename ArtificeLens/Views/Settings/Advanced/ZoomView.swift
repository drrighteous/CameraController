//
//  ZoomView.swift
//  ArtificeLens
//
//

import SwiftUI

struct ZoomView: View {
    @ObservedObject var zoomAbsolute: NumberCaptureDeviceProperty

    init(controller: DeviceController) {
        self.zoomAbsolute = controller.zoomAbsolute
    }

    var body: some View {
        GenericControl(value: $zoomAbsolute.sliderValue,
                       step: zoomAbsolute.resolution,
                       range: zoomAbsolute.minimum...zoomAbsolute.maximum,
                       title: "Zoom",
                       imageName: "plus.magnifyingglass",
                       auto: nil,
                       help: "Controls digital zoom. When zoomed in, drag the preview to pan and tilt.")
    }
}
