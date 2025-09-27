//
//  MainTabView.swift
//  SparkPlay
//
//  Created by Assistant on 26/9/2025.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var eventStore: EventStore
    @EnvironmentObject private var userStore: UserStore
    @State private var showAddSheet = false
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Explore Tab
            HomeView()
                .tabItem {
                    Image(systemName: "safari.fill")
                    Text("Explore")
                }
                .tag(0)
            
            // Add Spark Tab (Middle) - Empty view that triggers sheet
            Color.clear
                .tabItem {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [.orange, .pink, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 50, height: 50)
                            .shadow(color: .pink.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Circle()
                            .stroke(.white, lineWidth: 2)
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .offset(y: -8)
                    Text("Create Spark")
                }
                .tag(1)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(2)
        }
        .tint(.orange)
        .onChange(of: selectedTab) { _, newValue in
            if newValue == 1 {
                showAddSheet = true
                // Reset to previous tab after showing sheet
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    selectedTab = 0
                }
            }
        }
        .onAppear {
            setupTabBarAppearance()
        }
        .sheet(isPresented: $showAddSheet) {
            NavigationStack { 
                AddSparkView()
                    .environmentObject(eventStore)
                    .environmentObject(userStore)
            }
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        
        // Add subtle shadow
        appearance.shadowImage = nil
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.1)
        
        // Selected item color
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemOrange
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemOrange,
            .font: UIFont.systemFont(ofSize: 11, weight: .medium)
        ]
        
        // Normal item color
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray,
            .font: UIFont.systemFont(ofSize: 11, weight: .regular)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    MainTabView()
        .environmentObject(EventStore())
        .environmentObject(UserStore())
}
