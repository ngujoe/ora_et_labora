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
        let id = UUID()
        let name: String
    }

    // A struct to represent the entire mystery group, containing the details
    struct RosaryMystery: Identifiable {
        let id = UUID()
        let groupName: String // e.g., "Joyful Mysteries"
        let days: [Day]  // e.g., "Mondays and Saturdays"
        let mysteries: [MysteryDetail] // The sub-variable holding the individual mysteries
    }
    
    let rosaryMysteries: [RosaryMystery] = [
        RosaryMystery(
            groupName: "Joyful Mysteries",
            days: [.wednesday,.saturday],
            mysteries: [
                MysteryDetail(name: "The Annunciation"),
                MysteryDetail(name: "The Visitation"),
                MysteryDetail(name: "The Nativity"),
                MysteryDetail(name: "The Presentation"),
                MysteryDetail(name: "The Finding of Jesus in the Temple")
            ]
        ),
        RosaryMystery(
            groupName: "Luminous Mysteries",
            days: [.thursday],
            mysteries: [
                MysteryDetail(name: "The Baptism of Jesus in the Jordan"),
                MysteryDetail(name: "The Wedding at Cana"),
                MysteryDetail(name: "The Proclamation of the Kingdom of God"),
                MysteryDetail(name: "The Transfiguration"),
                MysteryDetail(name: "The Institution of the Eucharist")
            ]
        ),
        RosaryMystery(
            groupName: "Sorrowful Mysteries",
            days: [.tuesday,.friday],
            mysteries: [
                MysteryDetail(name: "The Agony in the Garden"),
                MysteryDetail(name: "The Scourging at the Pillar"),
                MysteryDetail(name: "The Crowning with Thorns"),
                MysteryDetail(name: "The Carrying of the Cross"),
                MysteryDetail(name: "The Crucifixion")
            ]
        ),
        RosaryMystery(
            groupName: "Glorious Mysteries",
            days: [.wednesday,.sunday],
            mysteries: [
                MysteryDetail(name: "The Resurrection"),
                MysteryDetail(name: "The Ascension"),
                MysteryDetail(name: "The Descent of the Holy Spirit (Pentecost)"),
                MysteryDetail(name: "The Assumption of Mary"),
                MysteryDetail(name: "The Coronation of Mary")
            ]
        )
    ]
    
    let rosarySections = [
        RosarySection(title: "Beginning", index: 0),
        RosarySection(title: "Apostles Creed", index: 1),
        RosarySection(title: "1st Mystery", index: 7),
        RosarySection(title: "2nd Mystery", index: 21),
        RosarySection(title: "3rd Mystery", index: 35),
        RosarySection(title: "4th Mystery", index: 49),
        RosarySection(title: "5th Mystery", index: 63),
        RosarySection(title: "Hail Holy Queen", index: 77)
    ]

    
    var body: some View {
        ZStack {
            VStack {
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(rosarySections) { section in
                            Button(section.title) {
                                currentPrayerIndex = section.index
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
                
                // Display the current prayer name and text
                if let prayer = currentPrayer {
                    VStack(spacing: 20) {
                        Spacer()
                        Text(prayer.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        if prayer.id.contains("hail_mary") && prayer.id.contains("opening"){
                            let components = prayer.id.split(separator: "_")
                            
                            // Safely get the last component and convert it to an integer.
                            if let lastComponent = components.last, let number = Int(lastComponent) {
                                Text("\(number)/3")
                                    .font(.title3)
                            }
                        } else if prayer.id.contains("hail_mary") && prayer.id.contains("mystery"){
                            let components = prayer.id.split(separator: "_")
                            
                            // Safely get the last component and convert it to an integer.
                            if let lastComponent = components.last, let number = Int(lastComponent) {
                                Text("\(number)/10")
                                    .font(.title3)
                            }
                        }
                        ScrollView{
                            Text(prayer.text)
                                .font(.system(size: 20 * appSettings.fontScale))
                                .multilineTextAlignment(.center)
                                .padding()
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
                    // Previous button
                    Button(action: previousPrayer) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(currentPrayerIndex == 0 ? .gray : .blue)
                    }
                    .padding(.horizontal)
                    // Disable the button if it's the first prayer
                    .disabled(currentPrayerIndex == 0)
                    
                    Spacer()
                    
                    // Next button
                    Button(action: nextPrayer) {
                        Image(systemName: "plus.circle.fill")
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
        .onAppear(perform: loadPrayers)
    }
    
    // Function to move to the next prayer
    func nextPrayer() {
        if currentPrayerIndex < prayers.count - 1 {
            currentPrayerIndex += 1
        }
    }
    
    // Function to move to the previous prayer
    func previousPrayer() {
        if currentPrayerIndex > 0 {
            currentPrayerIndex -= 1
        }
    }
    
    // Function to load prayers from JSON
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
