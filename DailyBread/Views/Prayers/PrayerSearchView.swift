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
                            .font(.system(size: 20 * appSettings.fontScale))// TODO: * appSettings.fontScale add this when ready because it keeps crashing preview
                        
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
    
    var body: some View {
        NavigationStack{
            List(prayerItem) { item in
                NavigationLink(destination: PrayerDetailView(prayerName: item.name, prayerText: item.text)) {
                    Text(item.name)

                }
            }
            .onAppear {
                prayerItem = loadPrayers() // Call your data loading function
            }
            .navigationTitle("Prayer Catalog")
        }
    }
}

#Preview{
    PrayerSearchView()
}
