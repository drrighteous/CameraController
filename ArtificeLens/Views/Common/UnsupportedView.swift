//
//  UnsupportedView.swift
//  ArtificeLens
//
//

import SwiftUI

struct UnsupportedView: View {
    var body: some View {
        VStack(spacing: 3) {
            Spacer()

            Text("Unsupported Camera")
                .font(.system(size: 20).bold())

            Text("Please connect a UVC compliant camera.")
                .font(.caption.bold())

            Spacer()
        }
    }
}

#if DEBUG
struct UnsupportedView_Previews: PreviewProvider {
    static var previews: some View {
        UnsupportedView()
    }
}
#endif
