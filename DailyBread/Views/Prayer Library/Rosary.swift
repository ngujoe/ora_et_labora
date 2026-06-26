//
//  Rosary.swift
//  DailyBread
//
//  Created by Joseph Nguyen on 8/31/25.
//

import SwiftUI
import Foundation

struct Prayer: Codable, Identifiable {
    let id: String
    let name: String
    let text: String
}

struct RosaryView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSettings: AppSettings
    
    @State private var currentPrayerIndex = 0
    @State private var prayers: [Prayer] = []
    @State private var todaysMysteries: RosaryMystery?
    @State private var selectedMystery: RosaryMystery?
    @State private var showMysterySelector = false
    
    let screenName = "rosary_view"
    
    // A computed property to get the current prayer
    var currentPrayer: Prayer? {
        if prayers.indices.contains(currentPrayerIndex) {
            return prayers[currentPrayerIndex]
        }
        return nil
    }
    
    struct RosarySection: Identifiable {
        let id = UUID() // A unique ID for each button
        let title: String
        let index: Int
    }
    
    enum Day: String, CaseIterable {
        case sunday = "Sunday"
        case monday = "Monday"
        case tuesday = "Tuesday"
        case wednesday = "Wednesday"
        case thursday = "Thursday"
        case friday = "Friday"
        case saturday = "Saturday"
    }

    struct MysteryDetail: Identifiable {
        let id: String
        let name: String
        
        // Custom initializer to create the formatted ID
        init(name: String, index: Int) {
            self.name = name
            let formattedName = name.lowercased().replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
            self.id = "\(formattedName)_\(index)"
        }
    }

    struct RosaryMystery: Identifiable {
        let id = UUID()
        let groupName: String
        let days: [Day]
        let mysteries: [MysteryDetail]
    }

    // Data source for the Rosary Mysteries
    let rosaryMysteries: [RosaryMystery] = [
        RosaryMystery(
            groupName: "Glorious Mysteries",
            days: [.sunday, .wednesday],
            mysteries: [
                MysteryDetail(name: "The Resurrection", index: 1),
                MysteryDetail(name: "The Ascension", index: 2),
                MysteryDetail(name: "The Descent of the Holy Spirit (Pentecost)", index: 3),
                MysteryDetail(name: "The Assumption of Mary", index: 4),
                MysteryDetail(name: "The Coronation of Mary", index: 5)
            ]
        ),
        RosaryMystery(
            groupName: "Joyful Mysteries",
            days: [.monday, .saturday],
            mysteries: [
                MysteryDetail(name: "The Annunciation", index: 1),
                MysteryDetail(name: "The Visitation", index: 2),
                MysteryDetail(name: "The Nativity", index: 3),
                MysteryDetail(name: "The Presentation", index: 4),
                MysteryDetail(name: "The Finding of Jesus in the Temple", index: 5)
            ]
        ),
        RosaryMystery(
            groupName: "Luminous Mysteries",
            days: [.thursday],
            mysteries: [
                MysteryDetail(name: "The Baptism of Jesus in the Jordan", index: 1),
                MysteryDetail(name: "The Wedding at Cana", index: 2),
                MysteryDetail(name: "The Proclamation of the Kingdom of God", index: 3),
                MysteryDetail(name: "The Transfiguration", index: 4),
                MysteryDetail(name: "The Institution of the Eucharist", index: 5)
            ]
        ),
        RosaryMystery(
            groupName: "Sorrowful Mysteries",
            days: [.tuesday, .friday],
            mysteries: [
                MysteryDetail(name: "The Agony in the Garden", index: 1),
                MysteryDetail(name: "The Scourging at the Pillar", index: 2),
                MysteryDetail(name: "The Crowning with Thorns", index: 3),
                MysteryDetail(name: "The Carrying of the Cross", index: 4),
                MysteryDetail(name: "The Crucifixion", index: 5)
            ]
        )
    ]

    // Function to get the mysteries for a given day
    func getMysteries(for day: Day) -> RosaryMystery? {
        return rosaryMysteries.first { $0.days.contains(day) }
    }
    
    let rosarySections = [
        RosarySection(title: "Opening", index: 0),
        RosarySection(title: "Apostles Creed", index: 1),
        RosarySection(title: "1st Mystery", index: 7),
        RosarySection(title: "2nd Mystery", index: 21),
        RosarySection(title: "3rd Mystery", index: 35),
        RosarySection(title: "4th Mystery", index: 49),
        RosarySection(title: "5th Mystery", index: 63),
        RosarySection(title: "Hail Holy Queen", index: 77)
    ]
    

    func prayerView(for prayer: Prayer) -> some View {
        
        // A Group is used to return a single View from the function
        Group {
            if prayer.id.contains("hail_mary") && prayer.id.contains("opening") {
                let components = prayer.id.split(separator: "_")
                
                if let lastComponent = components.last, let number = Int(lastComponent) {
                    let numberOfPrayers = 3 // Assuming you want to show 3 filled circles
                    
                    HStack {
                        // Show filled circles for completed prayers
                        ForEach(1...number, id: \.self) { i in
                            Image(systemName: "circle.fill")
                                .foregroundStyle(.gray)
                                .font(i == number ? .title : .body)
                        }
                        
                        // Show empty circles for remaining prayers
                        if numberOfPrayers != number {
                            ForEach(1...(numberOfPrayers - number), id: \.self) { _ in
                                Image(systemName: "circle")
                            }
                        }
                    }
                }
            } else if prayer.id.contains("hail_mary") && prayer.id.contains("mystery") {
                let components = prayer.id.split(separator: "_")
                
                if let lastComponent = components.last, let number = Int(lastComponent) {
                    let numberOfPrayers = 10 // Assuming you want to show 3 filled circles
                    
                    HStack {
                        Spacer()
                        // Show filled circles for completed prayers
                        ForEach(1...number, id: \.self) { i in
                            Image(systemName: "circle.fill")
                                .foregroundStyle(.gray)
                                .font(i == number ? .title : .body)
                        }
                        
                        // Show empty circles for remaining prayers
                        if numberOfPrayers != number {
                            ForEach(1...(numberOfPrayers - number), id: \.self) { _ in
                                Image(systemName: "circle")
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {

            // Mystery selector — collapsed by default, tap row to expand, auto-closes on selection
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    showMysterySelector.toggle()
                }
            } label: {
                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("MYSTERIES")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .tracking(0.6)
                        Text(selectedMystery?.groupName ?? "None selected")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.primary)
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(showMysterySelector ? 180 : 0))
                        .animation(.spring(response: 0.3), value: showMysterySelector)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if showMysterySelector {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(rosaryMysteries) { mystery in
                            let isSelected = selectedMystery?.groupName == mystery.groupName
                            let isToday = todaysMysteries?.groupName == mystery.groupName
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    selectedMystery = mystery
                                    showMysterySelector = false
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Text(mystery.groupName.replacingOccurrences(of: " Mysteries", with: ""))
                                        .font(.subheadline.weight(isSelected ? .semibold : .regular))
                                    if isToday {
                                        Text("Today")
                                            .font(.caption2.weight(.medium))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Capsule().fill(isSelected ? .white.opacity(0.3) : Color.blue.opacity(0.15)))
                                    }
                                }
                                .foregroundStyle(isSelected ? .white : .primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(RoundedRectangle(cornerRadius: 12).fill(isSelected ? Color.blue : Color(.secondarySystemBackground)))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // Section jump bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(rosarySections) { section in
                        Button(section.title) {
                            currentPrayerIndex = section.index
                            AnalyticsManager.shared.logEvent(name: "button_tapped", parameters: [
                                "button_name": "rosary_section",
                                "view_name": "rosary_view"
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
                VStack(spacing: 16) {
                    // Prayer name / mystery title
                    if prayer.id.contains("mystery_title") {
                        if let mystery = selectedMystery {
                            let components = prayer.id.split(separator: "_")
                            if let last = components.last, let number = Int(last) {
                                let ordinals = ["First", "Second", "Third", "Fourth", "Fifth"]
                                let ordinal = number <= ordinals.count ? ordinals[number - 1] : "\(number)th"
                                VStack(spacing: 6) {
                                    Text(mystery.groupName.uppercased())
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(Color.blue)
                                        .tracking(0.5)
                                    Text("The \(ordinal) Mystery")
                                        .font(.title2.bold())
                                        .multilineTextAlignment(.center)
                                    Text(mystery.mysteries[number - 1].name)
                                        .font(.title3)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                            }
                        } else {
                            Text("Select a mystery set above")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text(prayer.name)
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                    }

                    prayerView(for: prayer)

                    if !prayer.id.contains("mystery_title") {
                        ScrollView {
                            Text(prayer.text)
                                .font(.system(size: 20 * appSettings.fontScale))
                                .lineSpacing(6)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 4)
                                .padding(.bottom, 8)
                        }
                    } else {
                        Spacer()
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
                // Left zone → previous prayer
                Button(action: previousPrayer) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(currentPrayerIndex == 0 ? Color(.quaternaryLabel) : Color.blue)
                            .padding(.leading, 32)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                }
                .disabled(currentPrayerIndex == 0)
                .buttonStyle(.plain)

                // Position counter
                Text("\(currentPrayerIndex + 1)/\(prayers.count)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.tertiary)
                    .monospacedDigit()
                    .frame(width: 52)

                // Right zone → next prayer
                Button(action: nextPrayer) {
                    HStack {
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(currentPrayerIndex == prayers.count - 1 ? Color(.quaternaryLabel) : Color.blue)
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
        
        .onAppear{
            loadPrayers()
            let todayDate = Date()
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: todayDate)
            
            let today: Day
            switch weekday {
            case 1: today = .sunday
            case 2: today = .monday
            case 3: today = .tuesday
            case 4: today = .wednesday
            case 5: today = .thursday
            case 6: today = .friday
            case 7: today = .saturday
            default: today = .monday
            }
            
            self.todaysMysteries = getMysteries(for: today)
            self.selectedMystery = self.todaysMysteries

            AnalyticsManager.shared.logScreenView(screenName: screenName)
        }
        .onDisappear{
            AnalyticsManager.shared.logScreenTime(screenName: screenName)
        }
    }
    
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
        if let url = Bundle.main.url(forResource: "rosary", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                self.prayers = try JSONDecoder().decode([Prayer].self, from: data)
            } catch {
                print("Error loading or decoding rosary.json: \(error)")
            }
        }
    }
}

#Preview {
    RosaryView()
        .environmentObject(AppSettings())
}
