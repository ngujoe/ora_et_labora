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
            /*
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
             */
            
            DailyReadingsView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Readings")
                }
            
            AllPrayersView()
                .tabItem {
                    Image(systemName: "book.closed")
                    Text("Prayer")
                }
            /*
            GabeView()
                .tabItem {
                    Image(systemName: "mic.fill")
                    Text("Gabe AI")
                }
             */

            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .preferredColorScheme(settings.isDarkMode ? .dark : .light)
    }
}

#Preview{
    ContentView()
        .environmentObject(AppSettings())
}
