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

    var body: some View {
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
                Spacer(minLength: 0)
                Image(systemName: "mic")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .padding(.horizontal)

            // Nearby events list
            ScrollView(showsIndicators: true) {
                LazyVStack(spacing: 16) {
                    ForEach(filteredEvents) { event in
                        EventCard(event: event)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }

            Spacer()

            // Bottom bar
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
        }
        .padding(.top)
        .sheet(isPresented: $showMapSheet) {
            NavigationStack {
                MapAccessView()
            }
        }
        .sheet(isPresented: $showAddSheet) {
            NavigationStack { AddSparkView() }
        }
    }
}

private extension HomeView {
    var filteredEvents: [Event] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return store.events }
        let q = searchText.lowercased()
        return store.events.filter { $0.title.lowercased().contains(q) }
    }
}

private struct EventCard: View {
    let event: Event

    var body: some View {
        ZStack {
            let borderColor: Color = event.isOwnChallenge ? .blue : .black.opacity(0.12)
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(borderColor, lineWidth: event.isOwnChallenge ? 2 : 1)
                )
                .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)

            HStack(alignment: .center, spacing: 14) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: event.avatarGradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 64, height: 64)
                    Text(event.initials)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 8) {
                    // Title row
                    HStack(alignment: .center, spacing: 10) {
                        Text(event.title)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.primary)

                        Pill(text: "\(event.distanceMeters)m")

                        Spacer(minLength: 8)

                    }

                    // Meta row
                    HStack(spacing: 16) {
                        Label("\(event.etaMinutes) min", systemImage: "clock")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if let responses = event.responsesCount, event.isOwnChallenge {
                            Label("\(responses) responses", systemImage: "figure.2.arms.open")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            Label("\(event.participants)", systemImage: "person.2")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()

                if !event.isOwnChallenge {
                    Button("View") {}
                        .buttonStyle(.borderedProminent)
                }
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct Pill: View {
    var text: String
    var foreground: Color = .primary
    var background: Color = Color.gray.opacity(0.15)

    var body: some View {
        Text(text)
            .font(.subheadline)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(foreground)
            .background(background, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    HomeView()
        .environmentObject(EventStore())
}


