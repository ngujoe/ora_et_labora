//
//  analytics.swift
//  DailyBread
//
//  Created by Joseph Nguyen on 9/1/25.
//

import SwiftUI
import FirebaseAnalytics

final class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private init() {}
    
    private var screenViewStartTimes: [String: Date] = [:]
    
    func logEvent(name eventName: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(eventName, parameters: parameters)
        print("✅ Logged Firebase event: \(eventName)")
    }
    
    func logScreenView(screenName: String) {
        screenViewStartTimes[screenName] = Date()
            Analytics.logEvent(AnalyticsEventScreenView, parameters: [
                AnalyticsParameterScreenName: screenName
            ])
            print("➡️ Logged screen view for: \(screenName)")
        }
    
    func logScreenTime(screenName: String) {
            // Check if a start time was recorded for this screen.
            guard let startTime = screenViewStartTimes[screenName] else {
                print("⚠️ Could not log screen time. No start time found for: \(screenName)")
                return
            }

            let duration = Date().timeIntervalSince(startTime)
            let durationInSeconds = Int(duration.rounded())

            // Log the event with the screen name and duration.
            Analytics.logEvent("screen_time", parameters: [
                "screen_name": screenName,
                "duration_seconds": durationInSeconds
            ])
            
            // Remove the start time from the dictionary.
            screenViewStartTimes.removeValue(forKey: screenName)
            
            print("⏱️ Logged screen time for \(screenName): \(durationInSeconds) seconds")
        }
    
    
}
