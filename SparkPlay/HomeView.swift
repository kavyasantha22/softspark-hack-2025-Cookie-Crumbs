//
//  HomeView.swift
//  SparkPlay
//
//  Created by Assistant on 26/9/2025.
//
import SwiftUI
import MapKit

struct HomeView: View {
    @EnvironmentObject private var store: EventStore
    @State private var searchText: String = ""
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
            span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
        )
    )

    private let sampleCoordinate = CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)

    @State private var showMapSheet: Bool = false
    @State private var showAddSheet: Bool = false
    @State private var isKeyboardVisible: Bool = false
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Scrollable content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hey There!👋")
                            .font(.system(size: 44, weight: .bold))
                        Text("Are you bored?")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    // Map
                    Map(position: $cameraPosition) {
                        Marker("", coordinate: sampleCoordinate)
                    }
                    .mapStyle(.standard)
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .padding(.horizontal)
                    .contentShape(Rectangle())
                    .onTapGesture { showMapSheet = true }

                    // Section title
                    Text("Nearby Sparks")
                        .font(.title2).bold()
                        .padding(.horizontal)

                    // Search field
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Search", text: $searchText)
                            .textFieldStyle(.plain)
                            .focused($isSearchFocused)
                        Spacer(minLength: 0)
                        Image(systemName: "mic")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding(.horizontal)

                    // Nearby events list
                    LazyVStack(spacing: 16) {
                        ForEach(filteredEvents) { event in
                            EventCard(event: event)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100) // Space for bottom bar
                }
            }
            
            // Fixed bottom bar (hidden when keyboard is visible)
            if !isKeyboardVisible {
                VStack {
                    Divider()
                    HStack {
                        Image(systemName: "location.north.circle")
                            .font(.system(size: 30))
                        Spacer()
                        ZStack {
                            Circle()
                                .strokeBorder(.primary, lineWidth: 2)
                                .frame(width: 52, height: 52)
                            Button {
                                showAddSheet = true
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 22, weight: .bold))
                            }
                        }
                        Spacer()
                        Image(systemName: "person.circle")
                            .font(.system(size: 32))
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(.regularMaterial)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showMapSheet) {
            NavigationStack {
                MapAccessView()
            }
        }
        .sheet(isPresented: $showAddSheet) {
            NavigationStack { AddSparkView() }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                isKeyboardVisible = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                isKeyboardVisible = false
            }
        }
    }
}

private extension HomeView {
    var filteredEvents: [Event] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return store.events }
        let q = searchText.lowercased()
        return store.events.filter { $0.name.lowercased().contains(q) || $0.location.lowercased().contains(q) }
    }
}

private struct EventCard: View {
    let event: Event
    @EnvironmentObject private var store: EventStore
    @State private var showingDetail = false

    var body: some View {
        Button {
            showingDetail = true
        } label: {
            VStack(spacing: 0) {
                // Image section
                Group {
                    if let url = event.imageURL {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .overlay {
                                    ProgressView()
                                        .tint(.secondary)
                                }
                        }
                    } else {
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.3)], 
                                startPoint: .topLeading, 
                                endPoint: .bottomTrailing
                            ))
                            .overlay {
                                VStack(spacing: 4) {
                                    Image(systemName: "sparkles")
                                        .font(.title2)
                                        .foregroundStyle(.white)
                                    Text(String(event.name.prefix(2)).uppercased())
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                }
                            }
                    }
                }
                .frame(height: 140)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))
                
                // Content section
                VStack(alignment: .leading, spacing: 12) {
                    // Title and status
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.name)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "clock.fill")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                                Text(timeLeftText)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        StatusPill(text: remainingText, isFull: event.isFull, isClosed: event.isClosed)
                    }
                    
                    // Location
                    HStack(spacing: 6) {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)
                        Text(event.location)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        Spacer()
                    }
                    
                    // People count and view button
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                            Text("\(event.participants)/\(event.maxParticipants)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Text("View")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.blue.opacity(0.1), in: Capsule())
                    }
                }
                .padding(16)
                .background(.regularMaterial)
                .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 20, bottomTrailingRadius: 20))
            }
        }
        .buttonStyle(.plain)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.quaternary, lineWidth: 0.5)
        )
        .sheet(isPresented: $showingDetail) {
            NavigationStack {
                SparkDetailView(event: event)
            }
        }
    }

    private var timeLeftText: String {
        if event.isEnded { return "Ended" }
        let f = DateComponentsFormatter()
        f.allowedUnits = [.hour, .minute]
        f.unitsStyle = .short
        let s = f.string(from: Date(), to: event.endsAt) ?? "soon"
        return s + " left"
    }

    private var remainingText: String {
        event.isFull ? "Full" : "\(event.remainingSlots) left"
    }
}

private struct StatusPill: View {
    let text: String
    let isFull: Bool
    let isClosed: Bool
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor, in: Capsule())
    }
    
    private var foregroundColor: Color {
        if isClosed { return .secondary }
        if isFull { return .white }
        return .primary
    }
    
    private var backgroundColor: Color {
        if isClosed { return .gray.opacity(0.2) }
        if isFull { return .red }
        return .green.opacity(0.2)
    }
}

#Preview {
    HomeView()
        .environmentObject(EventStore())
}


