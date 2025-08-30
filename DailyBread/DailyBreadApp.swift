//
//  DailyBreadApp.swift
//  DailyBread
//
//  Created by Joe on 7/29/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      print("Firebase configured")
    return true
  }
}

@main
struct DailyBreadApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var settings = AppSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .environment(\.fontScaleFactor, settings.fontScale)
                .preferredColorScheme(settings.isDarkMode ? .dark : .light)
        }
    }
}

