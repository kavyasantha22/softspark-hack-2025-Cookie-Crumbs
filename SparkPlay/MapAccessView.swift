//
//  MapAccessView.swift
//  SparkPlay
//
//  Created by Assistant on 26/9/2025.
//

import SwiftUI
import MapKit

struct MapAccessView: View {
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject private var store: EventStore
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var followsUser: Bool = true

    var body: some View {
        VStack(spacing: 12) {
            Map(position: $cameraPosition, interactionModes: .all) {
                UserAnnotation()
                
                // Custom Spark markers
                ForEach(store.events.filter { $0.coordinate != nil }) { event in
                    if let coordinate = event.coordinate {
                        Annotation(event.name, coordinate: coordinate) {
                            SparkMarker(event: event)
                        }
                    }
                }
            }
                .ignoresSafeArea(edges: .top)
                .onAppear {
                    locationManager.requestWhenInUse()
                }
                .onChange(of: locationManager.latestLocation) { _ in
                    if followsUser { cameraPosition = .userLocation(fallback: .automatic) }
                }

            controlBar
                .padding()
        }
        .navigationTitle("Map")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var controlBar: some View {
        HStack(spacing: 12) {
            Button {
                locationManager.requestWhenInUse()
            } label: {
                Label("Locate", systemImage: "location.fill")
            }

            Button {
                followsUser.toggle()
                if followsUser { cameraPosition = .userLocation(fallback: .automatic) }
            } label: {
                Label(followsUser ? "Following" : "Free", systemImage: followsUser ? "figure.walk.circle.fill" : "hand.draw")
            }

            Spacer()
        }
    }
}

private struct SparkMarker: View {
    let event: Event
    
    var body: some View {
        VStack(spacing: 2) {
            // Main spark icon
            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: 44, height: 44)
                    .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                
                Circle()
                    .fill(markerColor)
                    .frame(width: 36, height: 36)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            // Pointer
            Triangle()
                .fill(.white)
                .frame(width: 12, height: 8)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                .offset(y: -2)
        }
    }
    
    private var markerColor: Color {
        if event.isClosed { return .gray }
        if event.isFull { return .red }
        return .orange
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    NavigationStack { 
        MapAccessView()
            .environmentObject(EventStore())
    }
}


