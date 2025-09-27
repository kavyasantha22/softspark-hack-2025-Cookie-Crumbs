//
//  ProfileView.swift
//  SparkPlay
//
//  Created by Assistant on 26/9/2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var eventStore: EventStore
    @EnvironmentObject private var userStore: UserStore
    @EnvironmentObject private var notificationManager: NotificationManager
    @State private var showingImagePicker = false
    @State private var showingNameEditor = false
    @State private var editingName = ""
    @State private var showingNotificationSettings = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        // Profile Image
                        Button {
                            showingImagePicker = true
                        } label: {
                            Group {
                                if let profileImage = userStore.currentUser.profileImage {
                                    Image(uiImage: profileImage)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    ZStack {
                                        Circle()
                                            .fill(LinearGradient(
                                                colors: [.orange, .pink, .purple],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ))
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 40))
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(.white, lineWidth: 4)
                                    .shadow(color: .black.opacity(0.1), radius: 4)
                            )
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .font(.caption)
                                    .foregroundStyle(.white)
                                    .padding(8)
                                    .background(LinearGradient(
                                        colors: [.orange, .pink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ), in: Circle())
                                    .offset(x: 30, y: 30)
                            )
                        }
                        .sheet(isPresented: $showingImagePicker) {
                            CameraCapture(isShown: $showingImagePicker, image: .constant(nil), onImageSelected: { image in
                                userStore.updateProfileImage(image)
                            })
                        }
                        
                        // Name
                        VStack(spacing: 8) {
                            Button {
                                editingName = userStore.currentUser.name
                                showingNameEditor = true
                            } label: {
                                HStack(spacing: 8) {
                                    Text(userStore.currentUser.name)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
                                    Image(systemName: "pencil")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                }
                            }
                            
                            Text("\(joinedSparks.count) Sparks joined")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top)
                    
                    // Spark Sections
                    VStack(spacing: 20) {
                        SparkSection(
                            title: "Active Sparks",
                            sparks: activeSparks,
                            emptyMessage: "No active sparks"
                        )
                        
                        SparkSection(
                            title: "Previously Joined",
                            sparks: endedSparks,
                            emptyMessage: "No previous sparks"
                        )
                        
                        SparkSection(
                            title: "My Created Sparks",
                            sparks: createdSparks,
                            emptyMessage: "You haven't created any sparks yet"
                        )
                    }
                    .padding(.horizontal)
                }
                
                // Settings Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    VStack(spacing: 8) {
                        Button {
                            showingNotificationSettings = true
                        } label: {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundStyle(.orange)
                                    .frame(width: 24)
                                
                                Text("Notifications")
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                    HStack(spacing: 4) {
                                        if notificationManager.isAuthorized {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.green)
                                                .font(.caption)
                                            Text("Enabled")
                                                .font(.caption)
                                                .foregroundStyle(.green)
                                        } else {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.red)
                                                .font(.caption)
                                            Text("Disabled")
                                                .font(.caption)
                                                .foregroundStyle(.red)
                                        }
                                    }
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding()
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("Profile")
        .alert("Edit Name", isPresented: $showingNameEditor) {
            TextField("Name", text: $editingName)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                userStore.updateName(editingName)
            }
        }
        .sheet(isPresented: $showingNotificationSettings) {
            NotificationSettingsView()
        }
    }
    
    // Computed properties for filtering sparks
    private var joinedSparks: [Event] {
        eventStore.events.filter { userStore.currentUser.joinedSparkIds.contains($0.id) }
    }
    
    private var activeSparks: [Event] {
        joinedSparks.filter { !$0.isEnded }
    }
    
    private var endedSparks: [Event] {
        joinedSparks.filter { $0.isEnded }
    }
    
    private var createdSparks: [Event] {
        eventStore.events.filter { userStore.currentUser.createdSparkIds.contains($0.id) }
    }
}

private struct SparkSection: View {
    let title: String
    let sparks: [Event]
    let emptyMessage: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(sparks.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.quaternary, in: Capsule())
            }
            
            if sparks.isEmpty {
                Text(emptyMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
                    .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(sparks) { spark in
                        ProfileSparkCard(spark: spark)
                    }
                }
            }
        }
    }
}

private struct ProfileSparkCard: View {
    let spark: Event
    @State private var showingDetail = false
    
    var body: some View {
        Button {
            showingDetail = true
        } label: {
            HStack(spacing: 12) {
                // Status indicator
                Circle()
                    .fill(statusColor)
                    .frame(width: 12, height: 12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(spark.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 12) {
                        Label(spark.location, systemImage: "location.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Label(statusText, systemImage: statusIcon)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingDetail) {
            NavigationStack {
                SparkDetailView(event: spark)
            }
        }
    }
    
    private var statusColor: Color {
        if spark.isEnded { return .gray }
        if spark.isFull { return .pink }
        return .orange
    }
    
    private var statusText: String {
        if spark.isEnded { return "Ended" }
        if spark.isFull { return "Full" }
        return "Active"
    }
    
    private var statusIcon: String {
        if spark.isEnded { return "clock.fill" }
        if spark.isFull { return "person.fill.checkmark" }
        return "checkmark.circle.fill"
    }
}


#Preview {
    ProfileView()
        .environmentObject(EventStore())
        .environmentObject(UserStore())
        .environmentObject(NotificationManager())
}
