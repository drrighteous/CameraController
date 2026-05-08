//
//  VisualEffectView.swift
//  ArtificeLens
//
//

import AppKit
import SwiftUI
import Foundation

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    var state: NSVisualEffectView.State

    func makeNSView(context: NSViewRepresentableContext<Self>) -> NSVisualEffectView {
        NSVisualEffectView()
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: NSViewRepresentableContext<Self>) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.state = state
    }
}
