//
//  LocationPickerView.swift
//  SparkPlay
//
//  Created by Assistant on 26/9/2025.
//

import SwiftUI
import MapKit
import CoreLocation

struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var address: String = ""

    let onPick: (_ name: String, _ lat: Double, _ lon: Double) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Map(position: $cameraPosition)
                .mapStyle(.standard)
                .overlay(alignment: .center) {
                    Image(systemName: "mappin.circle.fill").font(.title)
                        .foregroundStyle(.red)
                }
                .ignoresSafeArea(edges: .top)

            VStack(alignment: .leading, spacing: 8) {
                Text(address.isEmpty ? "Move the map, then tap Use This Location" : address)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack {
                    Button("Cancel") { dismiss() }
                    Spacer()
                    Button("My Location") {
                        if let current = locationManager.latestLocation?.coordinate {
                            selectedCoordinate = current
                            updateAddress(for: current)
                            // Move map to current location
                            cameraPosition = .region(MKCoordinateRegion(
                                center: current,
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            ))
                        } else {
                            // Request location if not available
                            locationManager.requestWhenInUse()
                        }
                    }
                    Button("Use This Location") {
                        let center = currentMapCenter()
                        selectedCoordinate = center
                        updateAddress(for: center)
                        onPick(address.isEmpty ? "Selected Location" : address, center.latitude, center.longitude)
                        dismiss()
                    }
                }
            }
            .padding()
            .background(.regularMaterial)
        }
        .navigationTitle("Pick Location")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            locationManager.requestWhenInUse()
        }
    }

    private func updateAddress(for coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
            if let p = placemarks?.first {
                address = [p.name, p.locality].compactMap { $0 }.joined(separator: ", ")
            }
        }
    }

    private func currentMapCenter() -> CLLocationCoordinate2D {
        if let region = cameraPosition.region {
            return region.center
        }
        if let camera = cameraPosition.camera {
            return camera.centerCoordinate
        }
        if let rect = cameraPosition.rect {
            let mid = MKMapPoint(x: rect.midX, y: rect.midY).coordinate
            return mid
        }
        return CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
    }

}
