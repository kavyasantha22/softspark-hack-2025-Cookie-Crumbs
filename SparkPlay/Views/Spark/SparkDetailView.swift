//
//  SparkDetailView.swift
//  SparkPlay
//
//  Created by Assistant on 26/9/2025.
//

import SwiftUI

struct SparkDetailView: View {
    let event: Event
    @EnvironmentObject private var store: EventStore
    @EnvironmentObject private var userStore: UserStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingJoinError = false
    @State private var joinErrorMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Hero Image
                Group {
                    if let imageURL = event.imageURLString, let url = URL(string: imageURL) {
                        // Try to load local file first
                        if imageURL.hasPrefix("file://") {
                            if let imageData = try? Data(contentsOf: url),
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                // Fallback to demo image
                                demoDetailImageForEvent(event)
                            }
                        } else {
                            // Load from internet URL
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Rectangle()
                                    .fill(.ultraThinMaterial)
                                    .overlay {
                                        ProgressView()
                                            .tint(.orange)
                                    }
                            }
                        }
                    } else {
                        // No image - show demo image
                        demoDetailImageForEvent(event)
                    }
                }
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal)
                
                // Content
                VStack(spacing: 20) {
                    // Title and Status
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top) {
                            Text(event.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            Spacer()
                            StatusPill(event: event)
                        }
                        
                        Text(event.descriptionText)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .lineLimit(nil)
                    }
                    .padding(.horizontal)
                    
                    // Quick Info Cards
                    VStack(spacing: 12) {
                        InfoCard(
                            icon: "clock.fill",
                            iconColor: .orange,
                            title: "Duration", 
                            value: timeLeftText
                        )
                        
                        InfoCard(
                            icon: "location.fill",
                            iconColor: .blue,
                            title: "Location", 
                            value: event.location
                        )
                        
                        InfoCard(
                            icon: "person.2.fill",
                            iconColor: .green,
                            title: "People", 
                            value: "\(event.participants) of \(event.maxParticipants) joined"
                        )
                    }
                    .padding(.horizontal)
                    
                    // Join Button
                    VStack(spacing: 12) {
                        Button {
                            handleJoinLeaveAction()
                        } label: {
                            HStack {
                                Image(systemName: buttonIcon)
                                    .font(.title3)
                                Text(buttonText)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundStyle(buttonTextColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(buttonBackground, in: RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(isButtonDisabled)
                        
                        if !event.isClosed && !hasJoined {
                            Text(buttonSubtext)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
        .alert("Cannot Join Spark", isPresented: $showingJoinError) {
            Button("OK") { }
        } message: {
            Text(joinErrorMessage)
        }
        .onAppear {
            // Refresh spark statuses when view appears
            store.refreshSparkStatuses()
        }
    }
    
    private var timeLeftText: String {
        if event.isEnded { return "Ended" }
        let f = DateComponentsFormatter()
        f.allowedUnits = [.hour, .minute]
        f.unitsStyle = .full
        let s = f.string(from: Date(), to: event.endsAt) ?? "soon"
        return s + " remaining"
    }
    
    private var hasJoined: Bool {
        userStore.hasJoined(event.id)
    }
    
    private var isCreator: Bool {
        userStore.currentUser.createdSparkIds.contains(event.id)
    }
    
    private var buttonText: String {
        if event.isClosed { return "Closed" }
        if isCreator { return "Your Spark" }
        if hasJoined { return "Leave Spark" }
        if event.isFull { return "Full" }
        return "Join Spark"
    }
    
    private var buttonIcon: String {
        if event.isClosed { return "xmark.circle" }
        if isCreator { return "crown.fill" }
        if hasJoined { return "minus.circle.fill" }
        if event.isFull { return "xmark.circle" }
        return "plus.circle.fill"
    }
    
    private var buttonTextColor: Color {
        if event.isClosed || event.isFull { return .secondary }
        if isCreator { return .white }
        if hasJoined { return .white }
        return .white
    }
    
    private var buttonBackground: Color {
        if event.isClosed || event.isFull { return Color.gray.opacity(0.2) }
        if isCreator { return .orange }
        if hasJoined { return .red }
        return .blue
    }
    
    private var isButtonDisabled: Bool {
        return event.isClosed || event.isFull || isCreator
    }
    
    private var buttonSubtext: String {
        if let activeSpark = userStore.currentActiveSpark(from: store.events) {
            return "You're already in '\(activeSpark.name)'. Leave it first to join this one."
        }
        return "Tap to join this Spark!"
    }
    
    private func handleJoinLeaveAction() {
        if hasJoined {
            // Leave the spark
            if store.leave(eventId: event.id) {
                // Successfully left
            } else {
                joinErrorMessage = "Unable to leave this Spark. Please try again."
                showingJoinError = true
            }
        } else {
            // Try to join the spark
            if store.join(eventId: event.id) {
                // Successfully joined
            } else {
                if userStore.currentActiveSpark(from: store.events) != nil {
                    joinErrorMessage = "You can only join one Spark at a time. Leave your current Spark first."
                } else if userStore.hasJoined(event.id) {
                    joinErrorMessage = "You've already joined this Spark."
                } else if event.isClosed {
                    joinErrorMessage = "This Spark is closed and no longer accepting participants."
                } else {
                    joinErrorMessage = "Unable to join this Spark. Please try again."
                }
                showingJoinError = true
            }
        }
    }
    
    // Now in scope for SparkDetailView
    private func demoDetailImageForEvent(_ event: Event) -> some View {
        let imageURL: String
        
        switch event.name.lowercased() {
        case let name where name.contains("chess"):
            imageURL = "https://images.unsplash.com/photo-1529699211952-734e80c4d42b?w=800&h=600&fit=crop"
        case let name where name.contains("football") || name.contains("soccer"):
            imageURL = "https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800&h=600&fit=crop"
        case let name where name.contains("drawing") || name.contains("art") || name.contains("paint"):
            imageURL = "https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=800&h=600&fit=crop"
        default:
            imageURL = "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800&h=600&fit=crop"
        }
        
        return AsyncImage(url: URL(string: imageURL)) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Rectangle()
                .fill(LinearGradient(
                    colors: [.orange.opacity(0.6), .pink.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .overlay {
                    ProgressView()
                        .tint(.white)
                }
        }
    }
}

private struct InfoCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            
            Spacer()
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct StatusPill: View {
    let event: Event
    
    var body: some View {
        Text(statusText)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(statusColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(statusBackground, in: Capsule())
    }
    
    private var statusText: String {
        if event.isClosed { return "Closed" }
        if event.isFull { return "Full" }
        return "\(event.remainingSlots) spots left"
    }
    
    private var statusColor: Color {
        if event.isClosed { return .secondary }
        if event.isFull { return Color.white }
        return .primary
    }
    
    private var statusBackground: Color {
        if event.isClosed { return Color.gray.opacity(0.2) }
        if event.isFull { return Color.red }
        return Color.green.opacity(0.2)
    }
}

#Preview {
    NavigationStack {
        SparkDetailView(event: Event(
            name: "Morning Hike",
            location: "Central Park",
            endsAt: Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date(),
            descriptionText: "Join us for a refreshing morning hike through the beautiful trails of Central Park. Perfect for all fitness levels!",
            imageURLString: nil,
            maxParticipants: 8,
            participants: 3
        ))
    }
    .environmentObject(EventStore())
    .environmentObject(UserStore())
}
