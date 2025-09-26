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
    @State private var durationHours: Int = 1
    @State private var durationMinutes: Int = 0
    @State private var isNotEnding: Bool = false
    @State private var descriptionText: String = ""
    @State private var peopleNeeded: Int = 3
    @State private var capturedImage: UIImage? = nil
    @State private var showCamera: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Activity Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Activity Name")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        TextField("What's the activity?", text: $name)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // Photo Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Photo")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        if let image = capturedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.quaternary, lineWidth: 1)
                                )
                        } else {
                            Button {
                                showCamera = true
                            } label: {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.quaternary)
                                    .frame(height: 120)
                                    .overlay {
                                        VStack(spacing: 8) {
                                            Image(systemName: "camera.fill")
                                                .font(.title2)
                                                .foregroundStyle(.secondary)
                                            Text("Add Photo")
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .sheet(isPresented: $showCamera) {
                        CameraCapture(isShown: $showCamera, image: $capturedImage)
                    }
                    
                    // Duration Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Duration")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        VStack(spacing: 16) {
                            Toggle(isOn: $isNotEnding) {
                                Text("No End Time")
                                    .font(.body)
                            }
                            .toggleStyle(.switch)
                            
                            if !isNotEnding {
                                HStack(spacing: 20) {
                                    Spacer()
                                    
                                    // Hours Picker
                                    VStack(spacing: 4) {
                                        Text("hours")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Picker("Hours", selection: $durationHours) {
                                            ForEach(0...23, id: \.self) { hour in
                                                Text("\(hour)").tag(hour)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(width: 70, height: 100)
                                    }
                                    
                                    // Minutes Picker
                                    VStack(spacing: 4) {
                                        Text("min")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Picker("Minutes", selection: $durationMinutes) {
                                            ForEach(Array(stride(from: 0, through: 59, by: 5)), id: \.self) { minute in
                                                Text("\(minute)").tag(minute)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(width: 70, height: 100)
                                    }
                                    
                                    Spacer()
                                }
                                
                                // End time display
                                if durationHours > 0 || durationMinutes > 0 {
                                    let endTime = Calendar.current.date(byAdding: .hour, value: durationHours, to: Calendar.current.date(byAdding: .minute, value: durationMinutes, to: Date()) ?? Date()) ?? Date()
                                    
                                    HStack {
                                        Image(systemName: "clock")
                                            .foregroundStyle(.secondary)
                                        Text("Ends at \(endTime.formatted(date: .omitted, time: .shortened))")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                    
                    // People Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("People Needed")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        HStack {
                            Button {
                                if peopleNeeded > 1 { peopleNeeded -= 1 }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(peopleNeeded > 1 ? .blue : .gray)
                            }
                            .disabled(peopleNeeded <= 1)
                            
                            Spacer()
                            
                            Text("\(peopleNeeded)")
                                .font(.title)
                                .fontWeight(.semibold)
                                .frame(minWidth: 40)
                            
                            Spacer()
                            
                            Button {
                                if peopleNeeded < 50 { peopleNeeded += 1 }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                            }
                        }
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                    
                    // Location Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Location")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        NavigationLink {
                            LocationPickerView { name, lat, lon in
                                location = name
                                latitude = lat
                                longitude = lon
                            }
                        } label: {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundStyle(.blue)
                                Text(location.isEmpty ? "Choose Location" : location)
                                    .foregroundStyle(location.isEmpty ? .secondary : .primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding()
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Description Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Description")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        TextField("Tell people what this activity is about...", text: $descriptionText, axis: .vertical)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                            .lineLimit(3...6)
                    }
                }
                .padding()
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
                    // Calculate end time based on duration
                    let endsAt = isNotEnding ? Date.distantFuture : Calendar.current.date(byAdding: .hour, value: durationHours, to: Calendar.current.date(byAdding: .minute, value: durationMinutes, to: Date()) ?? Date()) ?? Date()
                    let event = Event(name: name, location: location, endsAt: endsAt, descriptionText: descriptionText, imageURLString: imageURL, maxParticipants: peopleNeeded, participants: 0, latitude: latitude, longitude: longitude)
                    store.add(event)
                    dismiss()
                }
            }
        }
    }
    
    private func formatTimeRemaining(from start: Date, to end: Date) -> String {
        let interval = end.timeIntervalSince(start)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "0m"
        }
    }
}

#Preview {
    AddSparkView()
        .environmentObject(EventStore())
}


