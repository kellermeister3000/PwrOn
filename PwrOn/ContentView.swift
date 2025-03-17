//
//  ContentView.swift
//  PwrOn
//
//  Created by Philip Keller on 3/17/25.
//

import SwiftUI

enum NavigationTab {
    case explore
    case rentals
    case profile
}

struct ContentView: View {
    @State private var selectedTab: NavigationTab = .explore
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }
                .tag(NavigationTab.explore)
            
            ActiveRentalsView()
                .tabItem {
                    Label("Rentals", systemImage: "clock")
                }
                .tag(NavigationTab.rentals)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
                .tag(NavigationTab.profile)
        }
    }
}

#Preview {
    ContentView()
}
