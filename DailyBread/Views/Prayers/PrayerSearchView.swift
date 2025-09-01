//
//  PrayerSearchView.swift
//  DailyBread
//
//  Created by Joe on 7/31/25.
//

import SwiftUI
import Foundation

struct PrayerList: Codable{
    let prayerlist: [PrayerItem]
}
struct PrayerItem: Codable, Identifiable {
    var id: String
    var name: String
    var text: String
}

struct PrayerDetailView: View {
    // This view receives the name of the prayer
    let prayerName: String
    let prayerText: String
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        
        ScrollView{
            VStack{
                ZStack{
                    RoundedRectangle(cornerRadius: 20.0)
                        .fill(colorScheme == .dark ? .gray : .white) // TODO: || appSettings.isDarkMode
                        .opacity(0.50)
                        .shadow(radius: 10.0)
                        .padding(10)
                    VStack(alignment: .leading){
                        Text("\(prayerText)")
                            .font(.system(size: 20 * appSettings.fontScale))
                        Text("Copyright © Confraternity of Christian Doctrine, USCCB")
                            .font(.system(size: 12))
                            .padding(.top, 5)
                    }
                    .padding(30)
                }
                Spacer()
            }
            .navigationTitle(prayerName)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AllPrayersView: View {
    var body: some View {
        NavigationStack{
            ScrollView{
            NavigationLink(destination: RosaryView()) {
                ZStack {
                    Image("high-angle-open-bible-rosary-arrangement")
                        .resizable()
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal,10)
                    Text("The Rosary")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .background(Color.white.blur(radius: 15))
                        .shadow(radius: 50)
                        .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 200)
            
            NavigationLink(destination: PrayerSearchView()) {
                ZStack {
                    Image("prayer_image")
                        .resizable()
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal,10)
                    Text("Prayer Catalog")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .background(Color.white.blur(radius: 15))
                        .shadow(radius: 50)
                        .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 200)
            Spacer()
                .padding()
                .navigationTitle("Prayer")
        }
        }
    }
}

struct PrayerSearchView: View {
    
    @State private var prayerItem: [PrayerItem] = []
        
    func loadPrayers() -> [PrayerItem]{
        guard let url = Bundle.main.url(forResource: "prayers", withExtension: "json") else {
            fatalError("Failed to locate mydata.json in bundle.")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load mydata.json from bundle.")
        }
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode([PrayerItem].self, from: data) else {
            fatalError("Failed to decode mydata.json.")
        }
        return decodedData
    }
    
    @State private var searchText = ""
    
    
    var filteredPrayers: [PrayerItem] {
            guard !searchText.isEmpty else { return prayerItem }
            return prayerItem.filter { prayer in
                prayer.name.localizedCaseInsensitiveContains(searchText) ||
                prayer.text.localizedCaseInsensitiveContains(searchText)
            }
        }
    
    var body: some View {
        if filteredPrayers.isEmpty && !searchText.isEmpty {
            VStack {
                Spacer()
                Text("No prayers found.")
                    .foregroundColor(.secondary)
                    .font(.title3)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
            NavigationStack{
                     List(filteredPrayers) { item in
                         NavigationLink(destination: PrayerDetailView(prayerName: item.name, prayerText: item.text)) {
                             Text(item.name)
                         }
                     }
                     .searchable(text: $searchText, prompt: "Search for a prayer")
                     .onAppear {
                         prayerItem = loadPrayers() // Call your data loading function
                     }
                /*
                 List(filteredPrayers) { item in
                 NavigationLink(destination: PrayerDetailView(prayerName: item.name, prayerText: item.text)) {
                 Text(item.name)
                 }
                 }
                 */
            }
            .navigationTitle("Prayer Catalog")
            .searchable(text: $searchText, prompt: "Search for a prayer")
            .onAppear {
                prayerItem = loadPrayers() // Call your data loading function
            }
    }
}

#Preview{
    AllPrayersView()
        .environmentObject(AppSettings())
}
