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
    @StateObject private var userStore = UserStore()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(eventStore)
                .environmentObject(userStore)
                .onAppear {
                    eventStore.setUserStore(userStore)
                }
        }
    }
}
