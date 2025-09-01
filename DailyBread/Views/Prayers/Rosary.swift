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
    
    @State private var isSideMenuShowing = false
    @State private var currentPrayerIndex = 0
    @State private var prayers: [Prayer] = []

    // A computed property to get the current prayer
    var currentPrayer: Prayer? {
        if prayers.indices.contains(currentPrayerIndex) {
            return prayers[currentPrayerIndex]
        }
        return nil
    }

    var body: some View {
        ZStack {
            VStack {
                
                ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                Button("Beginning") {
                                    isSideMenuShowing = false
                                    currentPrayerIndex = 0
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(Color.gray.opacity(0.3))
                                .font(.title2)
                                .cornerRadius(10)
                                
                                Button("Apostles Creed") {
                                    isSideMenuShowing = false
                                    currentPrayerIndex = 1
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(Color.gray.opacity(0.3))
                                .font(.title2)
                                .cornerRadius(10)
                                
                                Button("1st Mystery") {
                                    isSideMenuShowing = false
                                    currentPrayerIndex = 7
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(Color.gray.opacity(0.3))
                                .font(.title2)
                                .cornerRadius(10)
                                
                                Button("2nd Mystery") {
                                    isSideMenuShowing = false
                                    currentPrayerIndex = 21
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(Color.gray.opacity(0.3))
                                .font(.title2)
                                .cornerRadius(10)
                                
                                Button("3rd Mystery") {
                                    isSideMenuShowing = false
                                    currentPrayerIndex = 35
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(Color.gray.opacity(0.3))
                                .font(.title2)
                                .cornerRadius(10)
                                
                                Button("4th Mystery") {
                                    isSideMenuShowing = false
                                    currentPrayerIndex = 49
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(Color.gray.opacity(0.3))
                                .font(.title2)
                                .cornerRadius(10)
                                
                                Button("5th Mystery") {
                                    isSideMenuShowing = false
                                    currentPrayerIndex = 63
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(Color.gray.opacity(0.3))
                                .font(.title2)
                                .cornerRadius(10)
                                
                                Button("Hail Holy Queen") {
                                    isSideMenuShowing = false
                                    currentPrayerIndex = 77
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(Color.gray.opacity(0.3))
                                .font(.title2)
                                .cornerRadius(10)
                            }
                            .padding()
                        }

                Spacer()
                
                // Display the current prayer name and text
                if let prayer = currentPrayer {
                    VStack(spacing: 20) {
                        Text(prayer.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(prayer.text)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                } else {
                    Text("Loading prayers...")
                        .font(.title)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                HStack {
                    // Previous button
                    Button(action: previousPrayer) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    // Disable the button if it's the first prayer
                    .disabled(currentPrayerIndex == 0)
                    
                    Spacer()
                    
                    // Next button
                    Button(action: nextPrayer) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    // Disable the button if it's the last prayer
                    .disabled(currentPrayerIndex == prayers.count - 1)
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
