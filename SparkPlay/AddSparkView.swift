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

    @State private var title: String = ""
    @State private var distanceMeters: Int = 100
    @State private var etaMinutes: Int = 5
    @State private var participants: Int = 1
    @State private var isOwnChallenge: Bool = false
    @State private var initials: String = "SP"
    @State private var startHex: String = "FF7E5F"
    @State private var endHex: String = "FD3A84"
    @State private var responsesCount: Int? = nil

    var body: some View {
        Form {
            Section("Details") {
                TextField("Title", text: $title)
                Stepper("Distance: \(distanceMeters)m", value: $distanceMeters, in: 10...5000, step: 10)
                Stepper("ETA: \(etaMinutes) min", value: $etaMinutes, in: 1...120)
                Stepper("Participants: \(participants)", value: $participants, in: 0...50)
                Toggle("Your Challenge", isOn: $isOwnChallenge)
                TextField("Initials", text: $initials)
#if os(iOS)
                    .textInputAutocapitalization(.characters)
#endif
            }

            Section("Gradient (hex)") {
                HStack {
                    TextField("Start (e.g. FF7E5F)", text: $startHex)
                    TextField("End (e.g. FD3A84)", text: $endHex)
                }
            }

            if isOwnChallenge {
                Section("Responses") {
                    Stepper("Responses: \(responsesCount ?? 0)", value: Binding(get: { responsesCount ?? 0 }, set: { responsesCount = $0 }), in: 0...100)
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
                    guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                    let event = Event(title: title, distanceMeters: distanceMeters, etaMinutes: etaMinutes, participants: participants, isOwnChallenge: isOwnChallenge, initials: initials, gradientStartHex: startHex, gradientEndHex: endHex, responsesCount: responsesCount)
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


