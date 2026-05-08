//
//  AdvancedView.swift
//  ArtificeLens
//
//

import SwiftUI

struct AdvancedView: View {
    @ObservedObject var controller: DeviceController

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: Constants.Style.controlsSpacing) {
                if controller.powerLineFrequency.isCapable {
                    PowerLineView(controller: controller)
                }

                if controller.backlightCompensation.isCapable {
                    BacklightView(controller: controller)
                }

                if controller.zoomAbsolute.isCapable {
                    ZoomView(controller: controller)
                }

                if controller.panTiltAbsolute.isCapable {
                    PanTiltView(controller: controller)
                }

                if controller.rollAbsolute.isCapable {
                    RollView(controller: controller)
                }

                if controller.focusAbsolute.isCapable {
                    FocusView(controller: controller)
                }
            }
            .padding(.top, 2)
            .padding(.bottom, Constants.Style.topSpacing)
        }
        .frame(maxHeight: 300)
    }
}
