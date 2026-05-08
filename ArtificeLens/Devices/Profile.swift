//
//  Profile.swift
//  ArtificeLens
//
//

import Foundation

struct Profile: Codable, Hashable {
    let name: String
    let isDefault: Bool
    let settings: DeviceSettings?

    init(name: String, settings: DeviceSettings) {
        self.name = name
        self.settings = settings
        self.isDefault = false
    }

    init() {
        self.name = "Camera Default"
        self.settings = nil
        self.isDefault = true
    }

    static func == (lhs: Profile, rhs: Profile) -> Bool {
        return lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
