//
//  SettingView.swift
//  DailyBread
//
//  Created by Joe on 7/29/25.
//

import SwiftUI
import Combine

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
        NavigationStack {
            Form {
                Section("Personal Settings") {
                    Toggle("Dark Mode", isOn: $settings.isDarkMode)
                        .onChange(of: settings.isDarkMode) { newValue in
                            AnalyticsManager.shared.logEvent(name: "setting_toggle", parameters: ["dark_mode": newValue])
                        }
                    Toggle("Mass Assistance", isOn: $settings.isNewCatMode)
                        .onChange(of: settings.isNewCatMode) { newValue in
                            AnalyticsManager.shared.logEvent(name: "setting_toggle", parameters: ["mass_assistance": newValue])
                        }
                    NavigationLink("Font Size") {
                        AdjustFontView()
                            .onAppear { AnalyticsManager.shared.logScreenView(screenName: "Font Size") }
                    }
                    Toggle("Format Daily Readings", isOn: $settings.formatReadings)
                        .onChange(of: settings.formatReadings) { newValue in
                            AnalyticsManager.shared.logEvent(name: "setting_toggle", parameters: ["format_daily_readings": newValue])
                        }
                }

                Section("Data Policies") {
                    NavigationLink("FAQ") {
                        Link("Please visit our FAQ page here.", destination: URL(string: "https://www.oraandlabora.org/")!)
                            .padding()
                    }
                    NavigationLink("Privacy Policy") {
                        Link("Please visit our Privacy Policy here.", destination: URL(string: "https://www.oraandlabora.org/privacy-policy")!)
                            .padding()
                    }
                }

                Section("Notes") {
                    NavigationLink {
                        SavedNotesListView()
                    } label: {
                        Label("Mass Notes", systemImage: "note.text")
                    }
                }

                Section {
                    Button {
                        showFeedbackForm = true
                        AnalyticsManager.shared.logEvent(name: "button_tapped", parameters: [
                            "button_name": "feedback_button",
                            "view_name": "settings_view"
                        ])
                    } label: {
                        Label("Send Feedback", systemImage: "envelope.fill")
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .sheet(isPresented: $showFeedbackForm) {
            FeedbackView(isPresented: $showFeedbackForm)
        }
    }
}

struct AdjustFontView: View {
    @EnvironmentObject var settings: AppSettings
    @Environment(\.fontScaleFactor) var fontScale

    var body: some View {
        Form {
            Section("Font Size") {
                VStack(alignment: .leading, spacing: 12) {
                    Slider(value: $settings.fontScale, in: 0.6...2.0, step: 0.2)

                    HStack {
                        Text("Small")
                        Spacer()
                        Text("Normal")
                        Spacer()
                        Text("Large")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    Text("John 3:16\n\nFor God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life.")
                        .font(.system(size: 16 * fontScale))
                        .padding(.top, 4)
                }
                .padding(.vertical, 8)
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

#Preview {
    SettingsView()
        .environmentObject(AppSettings())
}
