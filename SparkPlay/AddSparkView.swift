//
//  AddSparkView.swift
//  SparkPlay
//
//  Created by Assistant on 26/9/2025.
//

import SwiftUI

struct AddSparkView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: EventStore

    @State private var name: String = ""
    @State private var location: String = ""
    @State private var latitude: Double? = nil
    @State private var longitude: Double? = nil
    @State private var endsAt: Date = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
    @State private var descriptionText: String = ""
    @State private var maxParticipants: Int = 5
    @State private var participants: Int = 1
    @State private var capturedImage: UIImage? = nil
    @State private var showCamera: Bool = false

    var body: some View {
        Form {
            Section("Details") {
                TextField("Name", text: $name)
                DatePicker("Ends", selection: $endsAt, displayedComponents: [.date, .hourAndMinute])
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                Button("Insert Picture") {
                    showCamera = true
                }
                .sheet(isPresented: $showCamera) {
                    CameraCapture(isShown: $showCamera, image: $capturedImage)
                }
                TextField("Description", text: $descriptionText, axis: .vertical)
                    .lineLimit(3...6)
                Stepper("Max people: \(maxParticipants)", value: $maxParticipants, in: 1...200)
                Stepper("Currently joining: \(participants)", value: $participants, in: 0...maxParticipants)
            }

            Section("Location") {
                NavigationLink(location.isEmpty ? "Insert Location" : location) {
                    LocationPickerView { name, lat, lon in
                        location = name
                        latitude = lat
                        longitude = lon
                    }
                }
            }
        }
        .navigationTitle("Add Spark")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                    var imageURL: String? = nil
                    // Save captured image to Documents directory
                    if let image = capturedImage, let data = image.jpegData(compressionQuality: 0.8) {
                        let filename = UUID().uuidString + ".jpg"
                        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(filename)
                        try? data.write(to: url)
                        imageURL = url.absoluteString
                    }
                    let event = Event(name: name, location: location, endsAt: endsAt, descriptionText: descriptionText, imageURLString: imageURL, maxParticipants: maxParticipants, participants: participants, latitude: latitude, longitude: longitude)
                    store.add(event)
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    AddSparkView()
        .environmentObject(EventStore())
}


