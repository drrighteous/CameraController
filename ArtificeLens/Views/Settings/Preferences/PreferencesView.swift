//
//  PreferencesView.swift
//  ArtificeLens
//
//

import SwiftUI

struct PreferencesView: View {
    var body: some View {
        VStack(spacing: Constants.Style.controlsSpacing) {
            ApplicationSection()
            CameraSection()
            PreviewSection()
            ReadWriteSection()
            QuitButton()
        }
        .padding(.top, 2)
        .padding(.bottom, Constants.Style.topSpacing)
    }
}

#if DEBUG
struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
#endif
