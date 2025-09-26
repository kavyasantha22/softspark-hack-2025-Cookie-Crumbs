//
//  SparkPlayApp.swift
//  SparkPlay
//
//  Created by Putu Kavya Santha Guna on 26/9/2025.
//

import SwiftUI

@main
struct SparkPlayApp: App {
    @StateObject private var eventStore = EventStore()
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(eventStore)
        }
    }
}
