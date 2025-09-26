//
//  EventStore.swift
//  SparkPlay
//
//  Created by Assistant on 26/9/2025.
//

import Foundation
import Combine

final class EventStore: ObservableObject {
    @Published private(set) var events: [Event] = []
    private let fileURL: URL

    init(fileName: String = "events.json") {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documents.appendingPathComponent(fileName)
        load()
        if events.isEmpty {
            seed()
            save()
        }
    }

    func add(_ event: Event) {
        events.insert(event, at: 0)
        save()
    }

    func remove(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            events.remove(at: index)
        }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode([Event].self, from: data) {
            events = decoded
        }
    }

    private func save() {
        let data = (try? JSONEncoder().encode(events)) ?? Data()
        try? data.write(to: fileURL, options: [.atomic])
    }

    private func seed() {
        events = [
            Event(title: "Chess", distanceMeters: 150, etaMinutes: 12, participants: 1, isOwnChallenge: false, initials: "A", gradientStartHex: "FF7E5F", gradientEndHex: "FD3A84", responsesCount: nil),
            Event(title: "Football", distanceMeters: 300, etaMinutes: 8, participants: 3, isOwnChallenge: false, initials: "M", gradientStartHex: "FF7E5F", gradientEndHex: "FD3A84", responsesCount: nil),
            Event(title: "Drawing", distanceMeters: 220, etaMinutes: 5, participants: 0, isOwnChallenge: true, initials: "SP", gradientStartHex: "7B61FF", gradientEndHex: "2A9DF4", responsesCount: 2)
        ]
    }
}


