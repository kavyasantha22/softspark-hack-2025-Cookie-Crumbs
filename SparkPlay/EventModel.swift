//
//  EventModel.swift
//  SparkPlay
//
//  Created by Assistant on 26/9/2025.
//

import SwiftUI

struct Event: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var distanceMeters: Int
    var etaMinutes: Int
    var participants: Int
    var isOwnChallenge: Bool
    var initials: String
    // Store gradient as two color hex strings for Codable
    var gradientStartHex: String
    var gradientEndHex: String
    var responsesCount: Int?

    var avatarGradient: [Color] {
        [Color(hex: gradientStartHex), Color(hex: gradientEndHex)]
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}


