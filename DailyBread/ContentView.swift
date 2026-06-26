//
//  ContentView.swift
//  DailyBread
//
//  Created by Joe on 7/29/25.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var settings = AppSettings()
    
    var body: some View {
        TabView {
            DailyReadingsView()
                .tabItem {
                    Label("Readings", systemImage: "book.pages.fill")
                }

            AllPrayersView()
                .tabItem {
                    Label("Prayer", systemImage: "hands.sparkles.fill")
                }

            ThreePartProcessView()
                .tabItem {
                    Label("Confession", systemImage: "heart.circle.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(.blue)
        .environment(\.fontScaleFactor, settings.fontScale)
        .preferredColorScheme(settings.isDarkMode ? .dark : .light)
    }
}

#Preview{
    ContentView()
        .environmentObject(AppSettings())
}
