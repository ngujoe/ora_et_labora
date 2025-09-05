//
//  SettingView.swift
//  DailyBread
//
//  Created by Joe on 7/29/25.
//

import SwiftUI
import Combine

// usage
//Color(hex: "F7F79C")
    //.edgesIgnoringSafeArea(.all)
extension Color {
    init?(hex: String, alpha: Double = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        var r: Double = 0.0
        var g: Double = 0.0
        var b: Double = 0.0

        let length = hexSanitized.count
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = Double((rgb & 0xFF0000) >> 16) / 255.0
            g = Double((rgb & 0x00FF00) >> 8) / 255.0
            b = Double(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            r = Double((rgb & 0xFF000000) >> 24) / 255.0
            g = Double((rgb & 0x00FF0000) >> 16) / 255.0
            b = Double((rgb & 0x0000FF00) >> 8) / 255.0
            // Alpha is already in the `alpha` parameter for this example,
            // but could be extracted from the hex string if desired.
        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: alpha)
    }
}

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var showFeedbackForm = false
    
    var body: some View {
        ZStack (alignment: .bottom){
            NavigationStack{
                Form { // Settings Form
                    Section(header: Text("Personal Settings").font(.headline)) {
                        Toggle("Dark Mode", isOn: $settings.isDarkMode)
                            .onChange(of: settings.isDarkMode) { newValue in
                                        // Log a custom event with the new state
                                        AnalyticsManager.shared.logEvent(name: "setting_toggle", parameters: [
                                            "dark_mode": newValue
                                        ])
                                        print("🔔 Dark Mode toggle changed to: \(newValue)")
                                    }
                        Toggle("Mass Assistance", isOn: $settings.isNewCatMode)
                            .onChange(of: settings.isNewCatMode) { newValue in
                                        // Log a custom event with the new state
                                        AnalyticsManager.shared.logEvent(name: "setting_toggle", parameters: [
                                            "mass_assistance": newValue
                                        ])
                                        print("🔔 Mass Assistance toggle changed to: \(newValue)")
                                    }
                        NavigationLink("Font Size"){
                            AdjustFontView()
                                .onAppear{
                                    AnalyticsManager.shared.logScreenView(screenName: "Font Size")
                                }
                            }
                        Toggle("Format Daily Readings", isOn: $settings.formatReadings)
                            .onChange(of: settings.formatReadings) { newValue in
                                        // Log a custom event with the new state
                                        AnalyticsManager.shared.logEvent(name: "setting_toggle", parameters: [
                                            "format_daily_readings": newValue
                                        ])
                                        print("🔔 Format Daily Readings toggle changed to: \(newValue)")
                                    }
                        
                    }
                    Section(header: Text("Data Policies").font(.headline)) {
                        NavigationLink("FAQ"){
                            Link("Please visit our FAQ page here.", destination: URL(string: "https://www.oraandlabora.org/")!)
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 20.0)
                                        .fill(settings.isDarkMode ? .gray : .white)
                                        .opacity(0.50)
                                        .shadow(radius: 10.0)
                                        .padding(10)
                                )
                        }
                        NavigationLink("Privacy Policy"){
                            Link("Please visit our Privacy Policy here.", destination: URL(string: "https://www.oraandlabora.org/privacy-policy")!)
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 20.0)
                                        .fill(settings.isDarkMode ? .gray : .white)
                                        .opacity(0.50)
                                        .shadow(radius: 10.0)
                                        .padding(10)
                                )
                        }
                    }
                }
                .navigationTitle("Settings")
            }
            Button(action: {
                withAnimation(.spring()) {
                    self.showFeedbackForm = true
                }
            }) {
                Text("Feedback")
                    .padding(15)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray)
                            .padding(10)
                    )
                    .opacity(0.7)
                    .foregroundColor(.white)
                    .shadow(radius: 10)
            }
            .padding()
            
            // The feedback form wrapper that appears on top of everything
            if showFeedbackForm {
                FeedbackFormWrapper(showFeedbackForm: $showFeedbackForm)
                    .transition(.scale.animation(.spring(response: 0.5, dampingFraction: 0.8)))
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct AdjustFontView: View {
    @EnvironmentObject var settings: AppSettings
    @Environment(\.fontScaleFactor) var fontScale

    var body: some View {
        Form {
            Section(header: Text("Font Size")) {
                VStack(alignment: .leading) {
                    Text("Adjust Font Size")
                        .font(.headline)

                    Slider(value: $settings.fontScale, in: 0.6...2.0, step: 0.2)
                    
                    HStack {
                        Text("Small")
                        Spacer()
                        Text("Normal")
                        Spacer()
                        Text("Large")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)

                    Text("John 3:16\n\nFor God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life.")
                        .font(.system(size: 16 * fontScale))
                        .padding(.top)
                }
                .padding()
            }
        }
        .navigationTitle("Font Size")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FontScaleKey: EnvironmentKey {
    static let defaultValue: Double = 1.0
}

extension EnvironmentValues {
    var fontScaleFactor: Double {
        get { self[FontScaleKey.self] }
        set { self[FontScaleKey.self] = newValue }
    }
}


class AppSettings: ObservableObject {
    @AppStorage("fontScale") var fontScale: Double = 1.0
    @AppStorage("isDarkMode") var isDarkMode = false
    @AppStorage("isNewCatMode") var isNewCatMode = false
    @AppStorage("formatReadings") var formatReadings = false
}

#Preview{
    SettingsView()
        .environmentObject(AppSettings())
}
