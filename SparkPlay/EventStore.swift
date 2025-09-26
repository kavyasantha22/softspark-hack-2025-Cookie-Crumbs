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
    private weak var userStore: UserStore?

    init(fileName: String = "events.json") {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documents.appendingPathComponent(fileName)
        load()
        if events.isEmpty {
            seed()
            save()
        }
    }
    
    func setUserStore(_ userStore: UserStore) {
        self.userStore = userStore
    }

    func add(_ event: Event) {
        events.insert(event, at: 0)
        userStore?.createSpark(event.id)
        save()
    }

    func join(eventId: UUID) {
        guard let idx = events.firstIndex(where: { $0.id == eventId }) else { return }
        var e = events[idx]
        guard !e.isClosed else { return }
        e.participants = min(e.participants + 1, e.maxParticipants)
        events[idx] = e
        userStore?.joinSpark(eventId)
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
        let now = Date()
        events = [
            Event(name: "Chess", location: "Park Pavilion", endsAt: Calendar.current.date(byAdding: .minute, value: 90, to: now)!, descriptionText: "Casual chess games.", imageURLString: nil, maxParticipants: 4, participants: 1, latitude: 37.7849, longitude: -122.4094),
            Event(name: "Football", location: "Riverside Field", endsAt: Calendar.current.date(byAdding: .minute, value: 120, to: now)!, descriptionText: "5-a-side pickup.", imageURLString: nil, maxParticipants: 10, participants: 3, latitude: 37.7849, longitude: -122.4074),
            Event(name: "Drawing", location: "Community Hall", endsAt: Calendar.current.date(byAdding: .minute, value: 60, to: now)!, descriptionText: "Sketch session.", imageURLString: nil, maxParticipants: 5, participants: 2, latitude: 37.7829, longitude: -122.4084)
        ]
    }
}


