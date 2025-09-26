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
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var followsUser: Bool = true

    var body: some View {
        VStack(spacing: 12) {
            Map(position: $cameraPosition, interactionModes: .all) {
                UserAnnotation()
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

#Preview {
    NavigationStack { MapAccessView() }
}


