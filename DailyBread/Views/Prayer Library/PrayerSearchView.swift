//
//  PrayerSearchView.swift
//  DailyBread
//
//  Created by Joe on 7/31/25.
//

import SwiftUI
import Foundation

struct PrayerList: Codable {
    let prayerlist: [PrayerItem]
}

struct PrayerItem: Codable, Identifiable {
    var id: String
    var name: String
    var text: String
}

// MARK: - Prayer detail

struct PrayerDetailView: View {
    let prayerName: String
    let prayerText: String

    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(prayerText)
                    .font(.system(size: 20 * appSettings.fontScale))
                    .lineSpacing(6)
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Divider()
                    .padding(.horizontal, 24)

                Text("© Confraternity of Christian Doctrine, USCCB")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 3)
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(prayerName)
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Library home

struct AllPrayersView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    PrayerLibraryCard(
                        title: "The Rosary",
                        subtitle: "A guide to pray The Rosary",
                        imageName: "high-angle-open-bible-rosary-arrangement"
                    ) {
                        RosaryView()
                    }

                    DivineMercyCard()

                    PrayerLibraryCard(
                        title: "Prayer Archive",
                        subtitle: "Browse Catholic prayers",
                        imageName: "prayer_image"
                    ) {
                        PrayerSearchView()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Prayer Library")
        }
    }
}

private struct PrayerLibraryCard<Destination: View>: View {
    let title: String
    let subtitle: String
    let imageName: String
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        NavigationLink(destination: destination()) {
            ZStack(alignment: .bottomLeading) {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()

                LinearGradient(
                    colors: [.clear, .black.opacity(0.65)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding(20)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Divine Mercy card — full image on right, gaussian blur fills the left

private struct DivineMercyCard: View {
    var body: some View {
        NavigationLink(destination: DivineMercyView()) {
            ZStack(alignment: .bottomLeading) {
                // Dark base so the blurred edge blends cleanly
                Color.black

                // Clear image anchored to the right
                Image("divine_mercy_image")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                // Same image blurred, masked to cover the left portion only
                Image("divine_mercy_image")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .blur(radius: 24, opaque: true)
                    .mask(
                        LinearGradient(
                            stops: [
                                .init(color: .black, location: 0.0),
                                .init(color: .black, location: 0.42),
                                .init(color: .clear,  location: 0.68),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                // Subtle scrim for text legibility
                LinearGradient(
                    colors: [.black.opacity(0.5), .clear],
                    startPoint: .leading,
                    endPoint: .center
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text("Divine Mercy Chaplet")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    Text("A guide to pray the Divine Mercy Chaplet")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding(20)
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Prayer search / list

struct PrayerSearchView: View {
    @State private var prayerItem: [PrayerItem] = []
    @State private var searchText = ""

    var filteredPrayers: [PrayerItem] {
        guard !searchText.isEmpty else { return prayerItem }
        return prayerItem.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.text.localizedCaseInsensitiveContains(searchText)
        }
    }

    func loadPrayers() -> [PrayerItem] {
        guard let url = Bundle.main.url(forResource: "prayers", withExtension: "json") else {
            fatalError("Failed to locate prayers.json in bundle.")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load prayers.json from bundle.")
        }
        guard let decodedData = try? JSONDecoder().decode([PrayerItem].self, from: data) else {
            fatalError("Failed to decode prayers.json.")
        }
        return decodedData
    }

    var body: some View {
        List(filteredPrayers) { item in
            NavigationLink(destination: PrayerDetailView(prayerName: item.name, prayerText: item.text)) {
                Text(item.name)
                    .font(.body)
                    .padding(.vertical, 4)
            }
        }
        .listStyle(.insetGrouped)
        .searchable(text: $searchText, prompt: "Search prayers")
        .overlay {
            if filteredPrayers.isEmpty && !searchText.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundStyle(.quaternary)
                    Text("No prayers found")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Prayer Archive")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { prayerItem = loadPrayers() }
    }
}

#Preview {
    AllPrayersView()
        .environmentObject(AppSettings())
}
