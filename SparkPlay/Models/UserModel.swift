//
//  UserModel.swift
//  SparkPlay
//
//  Created by Assistant on 26/9/2025.
//

import SwiftUI
import Foundation
import Combine

struct User: Codable {
    var id: UUID = UUID()
    var name: String
    var profileImageData: Data?
    var joinedSparkIds: Set<UUID>
    var createdSparkIds: Set<UUID>
    
    init(name: String = "Your Name") {
        self.name = name
        self.profileImageData = nil
        self.joinedSparkIds = []
        self.createdSparkIds = []
    }
    
    var profileImage: UIImage? {
        guard let data = profileImageData else { return nil }
        return UIImage(data: data)
    }
}

final class UserStore: ObservableObject {
    @Published var currentUser: User
    private let fileURL: URL
    
    init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documents.appendingPathComponent("user.json")
        
        // Load existing user or create new one
        if let data = try? Data(contentsOf: fileURL),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
        } else {
            currentUser = User()
            save()
        }
    }
    
    func updateName(_ name: String) {
        currentUser.name = name
        save()
    }
    
    func updateProfileImage(_ image: UIImage?) {
        currentUser.profileImageData = image?.jpegData(compressionQuality: 0.8)
        save()
    }
    
    func joinSpark(_ sparkId: UUID) {
        currentUser.joinedSparkIds.insert(sparkId)
        save()
    }
    
    func leaveSpark(_ sparkId: UUID) {
        currentUser.joinedSparkIds.remove(sparkId)
        save()
    }
    
    func createSpark(_ sparkId: UUID) {
        currentUser.createdSparkIds.insert(sparkId)
        save()
    }
    
    // Helper to check if user has joined a specific spark
    func hasJoined(_ sparkId: UUID) -> Bool {
        return currentUser.joinedSparkIds.contains(sparkId)
    }
    
    // Helper to get current active spark (if any)
    func currentActiveSpark(from events: [Event]) -> Event? {
        for sparkId in currentUser.joinedSparkIds {
            if let event = events.first(where: { $0.id == sparkId && !$0.isEnded }) {
                return event
            }
        }
        return nil
    }
    
    // Remove user from ended/closed sparks
    func removeFromActiveSparks(eventId: UUID) {
        // This would typically be called when a spark ends
        // For now, we keep them in joinedSparkIds for history
        // but they won't show as "active" due to isEnded check
    }
    
    // Remove a spark from user's created sparks (when deleted)
    func removeSpark(_ sparkId: UUID) {
        currentUser.createdSparkIds.remove(sparkId)
        currentUser.joinedSparkIds.remove(sparkId)
        save()
    }
    
    // Remove a spark from all users' joined sparks (when spark is deleted)
    func removeSparkFromAllJoined(_ sparkId: UUID) {
        // Since we only track current user, just remove from current user
        currentUser.joinedSparkIds.remove(sparkId)
        save()
    }
    
    private func save() {
        let data = (try? JSONEncoder().encode(currentUser)) ?? Data()
        try? data.write(to: fileURL, options: [.atomic])
    }
}
