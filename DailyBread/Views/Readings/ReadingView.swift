//
//  TestingDailyReadingsView.swift
//  DailyBread
//
//  Created by Joe on 8/3/25.
//

import SwiftUI
import SwiftSoup

struct ReadingSetOption: Identifiable {
    let id = UUID()
    let name: String
    let urlString: String
}

struct ReadingView: View {
    @State private var selectedDate = Date()
    @State private var readings: [Reading] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showDatePicker = false
    @State private var showNotes = false
    @State private var noteExistsForSelectedDate = false
    @State private var scrollToID: String? = nil
    @State private var readingSetOptions: [ReadingSetOption] = []
    @State private var readingGroups: [[Reading]] = []
    @State private var readingGroupNames: [String] = []
    @State private var selectedSetIndex: Int = 0

    let screenName = "daily_readings_view"

    @Environment(\.colorScheme) var colorScheme

    private var hasMultipleOptions: Bool {
        readingSetOptions.count > 1 || readingGroups.count > 1
    }

    private var optionNames: [String] {
        if readingSetOptions.count > 1 { return readingSetOptions.map { $0.name } }
        if readingGroupNames.count > 1 { return readingGroupNames }
        return []
    }

    // MARK: - Body

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 12) {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 220)
                    } else if !readings.isEmpty {
                        ForEach(readings) { reading in
                            ReadingSectionView(
                                title: reading.title,
                                passage: reading.passage,
                                content: reading.content,
                                contentFormat: reading.contentFormat
                            )
                        }
                        onlineLinkCard
                    } else {
                        emptyStateView
                    }
                }
                .padding(.vertical, 12)
            }
            .background(Color(.systemGroupedBackground))
            .onChange(of: scrollToID) { _, newValue in
                scrollToSection(newValue, proxy: proxy)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            headerBar
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showNotes, onDismiss: refreshNoteBadge) {
            NavigationStack {
                MassNotesView(date: selectedDate, isSheet: true)
            }
        }
        .onAppear {
            fetchReadings(for: selectedDate)
            refreshNoteBadge()
            AnalyticsManager.shared.logScreenView(screenName: screenName)
        }
        .onDisappear {
            AnalyticsManager.shared.logScreenTime(screenName: screenName)
        }
    }

    // MARK: - Header

    @ViewBuilder
    private var headerBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Mass Readings")
                        .font(.title2.bold())
                    Text(selectedDate, style: .date)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()

                // Notes button — badge appears when a note exists for the selected date
                Button { showNotes = true } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "square.and.pencil")
                            .font(.title3)
                            .foregroundStyle(Color.primary)
                            .frame(width: 44, height: 44)
                        if noteExistsForSelectedDate {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 9, height: 9)
                                .offset(x: -1, y: 3)
                        }
                    }
                }
                .buttonStyle(.plain)

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        showDatePicker.toggle()
                    }
                } label: {
                    Image(systemName: showDatePicker ? "xmark.circle.fill" : "calendar")
                        .font(.title3)
                        .foregroundStyle(showDatePicker ? Color.secondary : Color.blue)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
            }

            if showDatePicker {
                HStack(spacing: 12) {
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                    Spacer()
                    Button("Update") {
                        fetchReadings(for: selectedDate)
                        refreshNoteBadge()
                        withAnimation { showDatePicker = false }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            if hasMultipleOptions {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(optionNames.enumerated()), id: \.offset) { index, name in
                            Button { selectReadingOption(index) } label: {
                                Text(name)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(selectedSetIndex == index ? .white : .primary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(
                                        Capsule()
                                            .fill(selectedSetIndex == index ? Color.blue : Color(.tertiarySystemBackground))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            if !readings.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(readings, id: \.title) { reading in
                            SectionPillButton(title: reading.title) {
                                scrollToID = reading.title
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                .ignoresSafeArea()
        }
    }

    // MARK: - Reusable cards

    private var onlineLinkCard: some View {
        Link(destination: URL(string: "https://bible.usccb.org/daily-bible-reading")!) {
            HStack(spacing: 12) {
                Image(systemName: "safari")
                    .font(.body)
                    .foregroundStyle(Color.blue)
                Text("Read the readings online at USCCB")
                    .font(.callout)
                    .foregroundStyle(Color.blue)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 52))
                .foregroundStyle(.quaternary)

            VStack(spacing: 8) {
                Text(errorMessage != nil ? "Couldn't Load Readings" : "No Readings Found")
                    .font(.title3.weight(.semibold))
                if let msg = errorMessage {
                    Text(msg)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
            }

            Button {
                fetchReadings(for: selectedDate)
            } label: {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(.body.weight(.medium))
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)

            Link("Open readings on USCCB website", destination: URL(string: "https://bible.usccb.org/daily-bible-reading")!)
                .font(.subheadline)
                .foregroundStyle(Color.blue)
        }
        .padding(36)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 3)
        )
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }

    // MARK: - Section jump pill

    struct SectionPillButton: View {
        let title: String
        let action: () -> Void

        var body: some View {
            let label = title == "Responsorial Psalm" ? "Psalm" : title
            Button(action: action) {
                Text(label)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(Color(.tertiarySystemBackground)))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Note badge

    private func refreshNoteBadge() {
        noteExistsForSelectedDate = NotesManager.shared.hasNote(for: selectedDate)
    }

    // MARK: - Scroll helper

    private func scrollToSection(_ id: String?, proxy: ScrollViewProxy) {
        guard let id else { return }
        withAnimation { proxy.scrollTo(id, anchor: .top) }
    }

    // MARK: - Option selection

    private func selectReadingOption(_ index: Int) {
        selectedSetIndex = index
        if !readingGroups.isEmpty && index < readingGroups.count {
            readings = readingGroups[index]
        } else if index < readingSetOptions.count {
            isLoading = true
            readings = []
            fetchReadingsFromSubPage(urlString: readingSetOptions[index].urlString)
        }
    }

    // MARK: - HTML parsing

    private func parseReadingsFromDoc(_ doc: Document) throws -> [Reading] {
        let blocks = try doc.select("div.innerblock")
        var fetchedReadings: [Reading] = []
        for block in blocks {
            let title = try block.select("h3.name").text()
            let passage = try block.select("div.address").text()
            let contentHtml = try block.select("div.content-body").html()
            let content = try SwiftSoup.parse(contentHtml.replacingOccurrences(of: "<br>", with: "\n")).text()
            let contentWithBreaks = contentHtml
                .replacingOccurrences(of: "  ", with: " ")
                .replacingOccurrences(of: "<br /> <br />  </p>", with: "")
                .replacingOccurrences(of: "R.", with: "\nR.")
                .replacingOccurrences(of: "</span>", with: "\n")
                .replacingOccurrences(of: "<span>", with: "\n")
                .replacingOccurrences(of: "<br /> ", with: "\n")
                .replacingOccurrences(of: "<br />", with: "\n")
                .replacingOccurrences(of: "<p>", with: "")
                .replacingOccurrences(of: "</p>", with: "")
                .replacingOccurrences(of: "<strong>", with: "")
                .replacingOccurrences(of: "</strong>", with: "\n")
                .replacingOccurrences(of: "</em>", with: "\n")
                .replacingOccurrences(of: "<em>", with: "\n")
            print("\(title): \(passage): \(content)")
            if title.contains("Reading") || title.contains("Psalm") || title.contains("Gospel") {
                fetchedReadings.append(Reading(title: title, passage: passage, content: content, contentFormat: contentWithBreaks))
            }
        }
        return fetchedReadings
    }

    private func splitIntoGroups(_ readings: [Reading]) -> [[Reading]] {
        var groups: [[Reading]] = [[]]
        var seenTitles = Set<String>()
        for reading in readings {
            if seenTitles.contains(reading.title) {
                groups.append([reading])
                seenTitles = [reading.title]
            } else {
                groups[groups.count - 1].append(reading)
                seenTitles.insert(reading.title)
            }
        }
        return groups.filter { !$0.isEmpty }
    }

    private func extractGroupNames(from doc: Document, count: Int) -> [String] {
        let headers = (try? doc.select("h2").array().compactMap { try? $0.text() }.filter { !$0.isEmpty }) ?? []
        let labels = ["A", "B", "C", "D"]
        return (0..<count).map { i in
            i < headers.count ? headers[i] : "Option \(i < labels.count ? labels[i] : "\(i + 1)")"
        }
    }

    private func detectSubPageOptions(doc: Document, formattedDate: String) throws -> [ReadingSetOption] {
        var options: [ReadingSetOption] = []
        for link in try doc.select("a[href]") {
            let href = try link.attr("href")
            let text = try link.text()
            guard !text.isEmpty,
                  href.contains("/readings/\(formattedDate)-") else { continue }
            let rawURL = href.hasPrefix("http") ? href : "https://bible.usccb.org\(href)"
            if !options.contains(where: { $0.urlString == rawURL }) {
                options.append(ReadingSetOption(name: text, urlString: rawURL))
            }
        }
        return options
    }

    // MARK: - Networking

    private func usccbRequest(for url: URL) -> URLRequest {
        URLRequest(url: url, timeoutInterval: 20)
    }

    private func fetchReadingsFromSubPage(urlString: String) {
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async { self.isLoading = false }
            return
        }
        URLSession.shared.dataTask(with: usccbRequest(for: url)) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
                return
            }
            guard let data = data, let html = String(data: data, encoding: .utf8) else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid response"
                    self.isLoading = false
                }
                return
            }
            do {
                let doc = try SwiftSoup.parse(html)
                let fetchedReadings = try self.parseReadingsFromDoc(doc)
                DispatchQueue.main.async {
                    self.readings = fetchedReadings
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Parsing error: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }.resume()
    }

    func fetchReadings(for date: Date) {
        isLoading = true
        errorMessage = nil
        readings = []
        readingSetOptions = []
        readingGroups = []
        readingGroupNames = []
        selectedSetIndex = 0

        if let cached = ReadingCacheManager.shared.load(for: date), !cached.isEmpty {
            self.readings = cached
            self.isLoading = false
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMddyy"
        let formattedDate = formatter.string(from: date)
        let urlString = "https://bible.usccb.org/bible/readings/\(formattedDate).cfm"

        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: usccbRequest(for: url)) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Network error — tap Retry: \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }

            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            guard let data = data,
                  let html = String(data: data, encoding: .utf8),
                  statusCode == 200 else {
                DispatchQueue.main.async {
                    self.errorMessage = statusCode != 200 && statusCode != 0
                        ? "Server returned \(statusCode) — tap Retry"
                        : "Could not read response — tap Retry"
                    self.isLoading = false
                }
                return
            }

            do {
                let doc = try SwiftSoup.parse(html)
                let fetchedReadings = try self.parseReadingsFromDoc(doc)

                let groups = self.splitIntoGroups(fetchedReadings)
                if groups.count > 1 {
                    let names = self.extractGroupNames(from: doc, count: groups.count)
                    DispatchQueue.main.async {
                        self.readingGroups = groups
                        self.readingGroupNames = names
                        self.selectedSetIndex = 0
                        self.readings = groups[0]
                        ReadingCacheManager.shared.save(readings: groups[0], for: date)
                        self.isLoading = false
                    }
                    return
                }

                if fetchedReadings.isEmpty {
                    let options = try self.detectSubPageOptions(doc: doc, formattedDate: formattedDate)
                    if !options.isEmpty {
                        DispatchQueue.main.async {
                            self.readingSetOptions = options
                            self.selectedSetIndex = 0
                        }
                        self.fetchReadingsFromSubPage(urlString: options[0].urlString)
                        return
                    }
                }

                DispatchQueue.main.async {
                    self.readings = fetchedReadings
                    ReadingCacheManager.shared.save(readings: fetchedReadings, for: date)
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Parsing error: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }.resume()
    }
}

// MARK: - Reading section card

struct ReadingSectionView: View {
    let title: String
    let passage: String
    let content: String
    let contentFormat: String

    @EnvironmentObject var settings: AppSettings
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.fontScaleFactor) var fontScale

    var body: some View {
        let updatedContent = title == "Responsorial Psalm" ? content.formattedResponsorialPsalm() : content
        let readingContent = settings.formatReadings ? contentFormat : updatedContent

        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title.uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.blue)
                    .tracking(0.5)
                Text(passage)
                    .font(.headline)
            }

            Divider()

            gospelBeginning(for: title)

            Text(readingContent)
                .font(.system(size: 18 * fontScale))
                .lineSpacing(5)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            readingEnd(for: title)

            Divider()

            Text("© Confraternity of Christian Doctrine, USCCB")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 3)
        )
        .padding(.horizontal, 16)
        .id(title)
    }

    private func gospelBeginning(for title: String) -> some View {
        Group {
            if title == "Gospel" && settings.isNewCatMode {
                Text("Priest: The Lord be with you.")
                    .font(.system(size: 18 * fontScale))
                Text("People: And with your Spirit")
                    .bold()
                    .font(.system(size: 18 * fontScale))
                Text("\nPriest: A reading from the holy Gospel according to...")
                    .font(.system(size: 18 * fontScale))
                Text("People: Glory to you, O Lord.\n")
                    .bold()
                    .font(.system(size: 18 * fontScale))
            }
        }
    }

    private func readingEnd(for title: String) -> some View {
        Group {
            if settings.isNewCatMode {
                if title.contains("Reading") {
                    Text("\nReader: The Word of the Lord")
                        .font(.system(size: 18 * fontScale))
                    Text("Response: Thanks be to God")
                        .bold()
                        .font(.system(size: 18 * fontScale))
                } else if title == "Gospel" {
                    Text("\nPriest: The Gospel of the Lord.")
                        .font(.system(size: 18 * fontScale))
                    Text("People: Praise to you, Lord Jesus Christ.")
                        .bold()
                        .font(.system(size: 18 * fontScale))
                }
            }
        }
    }
}

// MARK: - Cache

class ReadingCacheManager {
    static let shared = ReadingCacheManager()
    private init() {}

    func cacheFileURL(for date: Date) -> URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let fileName = "readings-\(formatter.string(from: date)).json"
        let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return directory.appendingPathComponent(fileName)
    }

    func save(readings: [Reading], for date: Date) {
        guard !readings.isEmpty else { return }
        do {
            let data = try JSONEncoder().encode(readings)
            try data.write(to: cacheFileURL(for: date))
        } catch {
            print("Failed to cache readings: \(error)")
        }
    }

    func load(for date: Date) -> [Reading]? {
        let url = cacheFileURL(for: date)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Reading].self, from: data)
        } catch {
            print("Failed to load cached readings: \(error)")
            return nil
        }
    }
}

// MARK: - Model

struct Reading: Codable, Identifiable {
    var id: String { title + passage }
    let title: String
    let passage: String
    let content: String
    let contentFormat: String
}

extension String {
    func formattedResponsorialPsalm() -> String {
        self
            .replacingOccurrences(of: "R.", with: "\n\nR.")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
