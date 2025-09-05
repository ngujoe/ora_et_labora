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
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(rosarySections) { section in
                            Button(section.title) {
                                currentPrayerIndex = section.index
                                AnalyticsManager.shared.logEvent(name: "button_tapped", parameters: [
                                                    "button_name": "rosary_section",
                                                    "view_name": "rosary_view"
                                                ])
                            }
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(Color.gray.opacity(0.3))
                            .font(.title2)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                // Display the current prayer name and text TODO: GET THE Rosary TITLES RIGHT
                if let prayer = currentPrayer {
                    VStack(spacing: 20) {
                        Spacer()
                        if prayer.id.contains("mystery_title") {
                            if let todaysMysteries = todaysMysteries {
                                let components = prayer.id.split(separator: "_")
                                if let lastComponent = components.last, let number = Int(lastComponent) {
                                    Text("The \(todaysMysteries.groupName):\n \(todaysMysteries.mysteries[number - 1].name)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                }
                            } else {
                                Text("No mysteries found for today.")
                            }
                        } else {
                            Text(prayer.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                        }
                        prayerView(for: prayer)
                        if prayer.id.contains("mystery_title") {
                            Spacer()
                        } else{
                            ScrollView{
                                Text(prayer.text)
                                    .font(.system(size: 20 * appSettings.fontScale))
                                    .multilineTextAlignment(.center)
                                    .padding()
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20.0)
                            .fill(colorScheme == .dark ? .gray : .white)
                            .opacity(0.50)
                            .shadow(radius: 10.0)
                            .padding(10)
                    )
                } else {
                    Text("Loading prayers...")
                        .font(.title)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button(action: previousPrayer) {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(currentPrayerIndex == 0 ? .gray : .blue)
                    }
                    .padding(.horizontal)
                    .disabled(currentPrayerIndex == 0)
                    
                    Spacer()
                    
                    Button(action: nextPrayer) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(currentPrayerIndex == prayers.count - 1 ? .gray : .blue)
                    }
                    .padding(.horizontal)
                    // Disable the button if it's the last prayer
                    .disabled(currentPrayerIndex == prayers.count - 1)
                    Spacer()
                }
                .padding()
            }
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
