//
//  EventModel.swift
//  SparkPlay
//
//  Created by Assistant on 26/9/2025.
//

import SwiftUI
import CoreLocation

struct Event: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    // Required attributes
    var name: String
    var location: String
    var endsAt: Date
    var descriptionText: String
    var imageURLString: String?
    var maxParticipants: Int
    var participants: Int
    // Optional coordinates
    var latitude: Double?
    var longitude: Double?

    // Derived
    var imageURL: URL? { imageURLString.flatMap { URL(string: $0) } }
    var isEnded: Bool { Date() >= endsAt }
    var isFull: Bool { participants >= maxParticipants }
    var isClosed: Bool { isEnded || isFull }
    var remainingSlots: Int { max(0, maxParticipants - participants) }
    var coordinate: CLLocationCoordinate2D? {
        if let lat = latitude, let lon = longitude { return CLLocationCoordinate2D(latitude: lat, longitude: lon) }
        return nil
    }
}



