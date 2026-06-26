//
//  DivineMercyView.swift
//  DailyBread
//
//  Created by Joe on 6/25/26.
//

import SwiftUI
import Foundation

struct DivineMercyView: View {

    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSettings: AppSettings

    @State private var currentPrayerIndex = 0
    @State private var prayers: [Prayer] = []

    let screenName = "divine_mercy_view"

    var currentPrayer: Prayer? {
        prayers.indices.contains(currentPrayerIndex) ? prayers[currentPrayerIndex] : nil
    }

    struct ChapletSection: Identifiable {
        let id = UUID()
        let title: String
        let index: Int
    }

    let chapletSections = [
        ChapletSection(title: "Opening",    index: 0),
        ChapletSection(title: "1st Decade", index: 4),
        ChapletSection(title: "2nd Decade", index: 15),
        ChapletSection(title: "3rd Decade", index: 26),
        ChapletSection(title: "4th Decade", index: 37),
        ChapletSection(title: "5th Decade", index: 48),
        ChapletSection(title: "Closing",    index: 59)
    ]

    // MARK: - Bead tracker

    @ViewBuilder
    func beadView(for prayer: Prayer) -> some View {
        if prayer.id.contains("decade_large") {
            // Single "Our Father" bead
            HStack(spacing: 10) {
                Image(systemName: "circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(Color.red.opacity(0.75))
                Text("Our Father bead")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        } else if prayer.id.contains("decade_small") {
            let components = prayer.id.split(separator: "_")
            if let lastComponent = components.last, let number = Int(lastComponent) {
                HStack(spacing: 5) {
                    ForEach(1...10, id: \.self) { i in
                        Image(systemName: "circle.fill")
                            .foregroundStyle(i <= number ? Color.red.opacity(0.75) : Color(.tertiaryLabel))
                            .font(i == number ? .body : .caption2)
                    }
                }
            }
        } else if prayer.id.contains("closing") {
            let components = prayer.id.split(separator: "_")
            if let lastComponent = components.last, let number = Int(lastComponent) {
                HStack(spacing: 8) {
                    ForEach(1...3, id: \.self) { i in
                        Image(systemName: "circle.fill")
                            .foregroundStyle(i <= number ? Color.red.opacity(0.75) : Color(.tertiaryLabel))
                            .font(i == number ? .title3 : .caption)
                    }
                }
            }
        }
    }

    // MARK: - Decade label

    private func decadeLabel(for prayer: Prayer) -> String? {
        let ordinals = ["First", "Second", "Third", "Fourth", "Fifth"]
        if prayer.id.contains("decade_large") || prayer.id.contains("decade_small") {
            let components = prayer.id.split(separator: "_")
            // ID format: decade_large_X or decade_small_X_Y — decade number is at index 2
            if components.count >= 3, let decadeNum = Int(components[2]) {
                let ordinal = decadeNum <= ordinals.count ? ordinals[decadeNum - 1] : "\(decadeNum)th"
                return "\(ordinal) Decade".uppercased()
            }
        } else if prayer.id.hasPrefix("opening") || prayer.id == "sign_of_cross" || prayer.id == "apostles_creed" {
            return "OPENING"
        } else if prayer.id.hasPrefix("closing") {
            return "CLOSING"
        }
        return nil
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {

            // Section jump bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(chapletSections) { section in
                        Button(section.title) {
                            currentPrayerIndex = section.index
                            AnalyticsManager.shared.logEvent(name: "button_tapped", parameters: [
                                "button_name": "divine_mercy_section",
                                "view_name": screenName
                            ])
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }

            Divider()

            // Prayer card
            if let prayer = currentPrayer {
                VStack(spacing: 14) {
                    // Section label
                    if let label = decadeLabel(for: prayer) {
                        Text(label)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.red.opacity(0.8))
                            .tracking(0.5)
                    }

                    // Prayer name
                    Text(prayer.name)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)

                    // Bead tracker
                    beadView(for: prayer)

                    // Prayer text
                    ScrollView {
                        Text(prayer.text)
                            .font(.system(size: 20 * appSettings.fontScale))
                            .lineSpacing(6)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 4)
                            .padding(.bottom, 8)
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 4)
                        .padding(12)
                )
            } else {
                Spacer()
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            Divider()

            // Navigation — full-width tap zones for no-look use
            HStack(spacing: 0) {
                Button(action: previousPrayer) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(currentPrayerIndex == 0 ? Color(.quaternaryLabel) : Color.red.opacity(0.8))
                            .padding(.leading, 32)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                }
                .disabled(currentPrayerIndex == 0)
                .buttonStyle(.plain)

                Text("\(currentPrayerIndex + 1)/\(prayers.count)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.tertiary)
                    .monospacedDigit()
                    .frame(width: 52)

                Button(action: nextPrayer) {
                    HStack {
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(currentPrayerIndex == prayers.count - 1 ? Color(.quaternaryLabel) : Color.red.opacity(0.8))
                            .padding(.trailing, 32)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                }
                .disabled(currentPrayerIndex == prayers.count - 1)
                .buttonStyle(.plain)
            }
            .frame(height: 88)
            .background(Color(.secondarySystemBackground))
        }
        .onAppear {
            loadPrayers()
            AnalyticsManager.shared.logScreenView(screenName: screenName)
        }
        .onDisappear {
            AnalyticsManager.shared.logScreenTime(screenName: screenName)
        }
    }

    // MARK: - Navigation

    func nextPrayer() {
        if currentPrayerIndex < prayers.count - 1 {
            currentPrayerIndex += 1
        }
    }

    func previousPrayer() {
        if currentPrayerIndex > 0 {
            currentPrayerIndex -= 1
        }
    }

    func loadPrayers() {
        guard let url = Bundle.main.url(forResource: "divinemercy", withExtension: "json") else {
            print("divinemercy.json not found in bundle")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            prayers = try JSONDecoder().decode([Prayer].self, from: data)
        } catch {
            print("Error loading divinemercy.json: \(error)")
        }
    }
}

#Preview {
    DivineMercyView()
        .environmentObject(AppSettings())
}
