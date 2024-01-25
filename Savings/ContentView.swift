//
//  ContentView.swift
//  Savings
//
//  Created by Baptiste Fortier on 24/01/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("home", systemImage: "house")
                }
            SettingsView()
                .tabItem {
                    Label("settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
}
