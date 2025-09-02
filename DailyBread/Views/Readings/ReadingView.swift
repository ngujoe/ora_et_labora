//
//  TestingDailyReadingsView.swift
//  DailyBread
//
//  Created by Joe on 8/3/25.
//

import SwiftUI
import SwiftSoup

struct ReadingView: View {
    @State private var selectedDate = Date()
    @State private var readings: [Reading] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var barHidden = true
    @State private var dateBarHide = false
    @State private var scrollToID: String? = nil
    @State private var hasScrolled = false
    @State private var rotation: Double = 0
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                
                ZStack(alignment: .top){
                    VStack{
                        Spacer().frame(height: 130)
                        ScrollView{
                            ZStack{
                                VStack {
                                    if isLoading {
                                        ProgressView()
                                    }
                                    else {
                                        if !readings.isEmpty{
                                            ForEach(readings) { reading in
                                                ReadingSectionView(title: reading.title, passage: reading.passage, content: reading.content, contentFormat: reading.contentFormat)
                                            }
                                            Link("Read the readings online here.", destination: URL(string: "https://bible.usccb.org/daily-bible-reading")!)
                                                .padding() // Add some padding so the text isn't on the edges
                                                .frame(maxWidth: .infinity, maxHeight: .infinity) // Make the text view fill the screen
                                                .background(
                                                    RoundedRectangle(cornerRadius: 20.0)
                                                        .fill(colorScheme == .dark ? .gray : .white)
                                                        .opacity(0.50)
                                                        .shadow(radius: 10.0)
                                                        .padding(10)
                                                )
                                        }
                                        else{
                                            
                                            Link("Read the readings online here.", destination: URL(string: "https://bible.usccb.org/daily-bible-reading")!)
                                                .padding() // Add some padding so the text isn't on the edges
                                                .frame(maxWidth: .infinity, maxHeight: .infinity) // Make the text view fill the screen
                                                .background(
                                                    RoundedRectangle(cornerRadius: 20.0)
                                                        .fill(colorScheme == .dark ? .gray : .white)
                                                        .opacity(0.50)
                                                        .shadow(radius: 10.0)
                                                        .padding(10)
                                                )
                                                .preferredColorScheme(.light)
                                            
                                        }
                                    }
                                }
                                
                                /*
                                 TODO: if the saint of the day is populated, then populate, it currently times out the view
                                .padding(.top, 130)
                                    VStack {
                                    NavigationLink (destination: SOTDView()){
                                        Text("Saint of the day")
                                            .frame(height: 130)
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                RoundedRectangle(cornerRadius: 20.0)
                                                    .fill(colorScheme == .dark ? .gray : .white)
                                                    .opacity(0.50)
                                                    .shadow(radius: 10.0)
                                                    .padding(10)
                                            )
                                    }
                                    Spacer()
                                }
                                */
                            }
                        }
                        .background(Color.clear)
                        .onChange(of: scrollToID) { _, newValue in
                            scrollToSection(newValue, proxy: proxy)
                        }
                    }
                    .padding(.top, 0)

                    if dateBarHide {
                        VStack(spacing: 0){
                            Spacer().frame(height: 95)
                            HStack{
                                VStack{
                                    DatePicker("Selected Date", selection: $selectedDate, displayedComponents: .date)
                                        .font(.system(size: 16))
                                }
                                Spacer()
                                Button(action: {
                                    fetchReadings(for: selectedDate)
                                    withAnimation {
                                        dateBarHide.toggle()
                                    }
                                    rotation += 180
                                }){
                                    Text("Update")
                                        .font(.system(size: 15))
                                        .foregroundColor(.white)
                                        .padding(7)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.blue)
                                        )
                                }
                                .disabled(isLoading)
                            }
                            .padding(.horizontal)
                            .padding(.bottom,5)
                            .frame(maxWidth: .infinity)
                            .frame(height: 130, alignment: .bottom)
                            .background(
                                RoundedRectangle(cornerRadius: 10.0)
                                    .fill(colorScheme == .dark ? .gray : .white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .shadow(radius: 10.0)
                                    .padding(.top, -55)
                                    .padding(.leading,0)
                                    .padding(.trailing,0)
                            )
                            .ignoresSafeArea(edges: .top)
                        }
                        .padding(.horizontal)
                        .frame(height: 160)
                        .transition(.move(edge: .top)) // move from top
                        .animation(.spring(), value: dateBarHide)
                    }
                    VStack(spacing: 5){
                        Button(action: {
                            withAnimation {
                                dateBarHide.toggle()
                            }
                            rotation += 180
                        }){
                            HStack{
                                Text("Mass Readings")
                                    .font(.title2)
                                    .foregroundStyle(.black)
                                    .fontWeight(.bold)
                                Image(systemName: "chevron.down")
                                    .resizable()
                                    .bold()
                                    .frame(width: 16, height: 8)
                                    .foregroundStyle(.black)
                                    .rotationEffect(.degrees(rotation))
                                    .animation(.easeInOut(duration: 0.5), value: rotation)

                            }
                        }
                        HStack(spacing: 15){
                            ForEach(readings, id: \.title) { reading in
                                ScrollButton(title: reading.title) {
                                    scrollToID = reading.title
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom,5)
                    .frame(maxWidth: .infinity)
                    .frame(height: 130, alignment: .bottom)
                    .background(
                        RoundedRectangle(cornerRadius: 10.0)
                            .fill(colorScheme == .dark ? .gray : .white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .shadow(radius: 10.0)
                            .padding(.top, -130)
                            .padding(.leading,0)
                            .padding(.trailing,0)
                    )
                    .ignoresSafeArea(edges: .top)
                }
                .ignoresSafeArea(edges: .top)
            }
        }
        .onAppear(){
            fetchReadings(for: selectedDate)
            if !hasScrolled{
                scrollToID = "Reading 1"
            }
        }
    }

    struct ScrollButton: View {
        let title: String
        let action: () -> Void
        
        var body: some View {
            
            let displayTitle = title == "Responsorial Psalm" ? "Res. Psalm" : title
            
            Button(action: action) {
                Text(displayTitle)
                    .font(.system(size:12))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                    )
            }
        }
    }
    
    private func scrollToSection(_ id: String?, proxy: ScrollViewProxy) {
        guard let id = id else { return }
        withAnimation {
            proxy.scrollTo(id, anchor: .top)
        }
    }
    
    func fetchReadings(for date: Date) {
        isLoading = true
        errorMessage = nil
        readings = []

        // ✅ Check cache first
        if let cached = ReadingCacheManager.shared.load(for: date) {
            self.readings = cached
            self.isLoading = false
            return
        }

        // 📅 Format date for URL
        let formatter = DateFormatter()
        formatter.dateFormat = "MMddyy"
        let formattedDate = formatter.string(from: date)
        let urlString = "https://bible.usccb.org/bible/readings/\(formattedDate).cfm"

        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }

            guard let data = data, let html = String(data: data, encoding: .utf8) else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid response"
                }
                return
            }

            do {
                let doc = try SwiftSoup.parse(html)
                let blocks = try doc.select("div.innerblock")

                var fetchedReadings: [Reading] = []

                for block in blocks {
                    let title = try block.select("h3.name").text()
                    let passage = try block.select("div.address").text()
                    let contentHtml = try block.select("div.content-body").html()
                    
                    let content = try SwiftSoup.parse(contentHtml.replacingOccurrences(of: "<br>", with: "\n")).text()
                    
                    let contentWithBreaks = contentHtml.replacingOccurrences(of: "  ", with: " ").replacingOccurrences(of: "<br /> <br />  </p>", with: "").replacingOccurrences(of: "R.", with: "\nR.").replacingOccurrences(of: "</span>", with: "\n").replacingOccurrences(of: "<span>", with: "\n").replacingOccurrences(of: "<br /> ", with: "\n").replacingOccurrences(of: "<br />", with: "\n").replacingOccurrences(of: "<p>", with: "").replacingOccurrences(of: "</p>", with: "").replacingOccurrences(of: "<strong>", with: "").replacingOccurrences(of: "</strong>", with: "\n").replacingOccurrences(of: "</em>", with: "\n").replacingOccurrences(of: "<em>", with: "\n")
                    
                    
                    print ("\(title): \(passage): \(content)")
                    print ("\(title): \(passage): \(contentWithBreaks)")
                    if title.contains("Reading") || title.contains("Psalm") || title.contains("Gospel") {
                        fetchedReadings.append(Reading(title: title, passage: passage, content: content, contentFormat:contentWithBreaks))
                    }
                }

                DispatchQueue.main.async {
                    self.readings = fetchedReadings
                    // 💾 Save to cache
                    ReadingCacheManager.shared.save(readings: fetchedReadings, for: date)
                }

            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Parsing error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

struct ReadingSectionView: View {
    let title: String
    let passage: String
    let content: String
    let contentFormat: String
    
    // TODO: Enable this when ready to launch since it crashes the preview
    @EnvironmentObject var settings: AppSettings
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.fontScaleFactor) var fontScale
    
    
    var body: some View {
        
        

        
        let updatedContent = title == "Responsorial Psalm" ? content.formattedResponsorialPsalm() : content
        let readingContenetToggled = settings.formatReadings ? contentFormat : updatedContent
        //ZStack {
            /*
            RoundedRectangle(cornerRadius: 20.0)
                .fill(colorScheme == .dark ? .gray : .white)
                .opacity(0.50)
                .shadow(radius: 10.0)
                .padding(10)
             */
            VStack(alignment: .leading){
                Text(title)
                    .bold()
                    .font(.system(size: 23 + (2 * fontScale)))
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                Text(passage)
                    .font(.system(size: 18 + (2 * fontScale)))
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 5)
                gospelBeginning(for: title)
                Text(readingContenetToggled)
                    .font(.system(size: 20 * fontScale))
                    .multilineTextAlignment(.leading)
                readingEnd(for: title)
                Text("Copyright © Confraternity of Christian Doctrine, USCCB")
                    .font(.system(size: 12))
                    .padding(.top, 5)
                    .multilineTextAlignment(.leading)
            }
            //.frame(maxWidth: .infinity)
            .padding(30)
        //}
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20.0)
                .fill(colorScheme == .dark ? .gray : .white)
                .opacity(0.50)
                .shadow(radius: 10.0)
                .padding(10)
        )
        .id(title)
    }
    
    private func gospelBeginning(for title: String) -> some View {
        Group {
            if title == "Gospel" && settings.isNewCatMode {
                Text("Priest: The Lord be with you.")
                    .font(.system(size: 18 * fontScale))
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                Text("People: And with your Spirit")
                    .bold()
                    .font(.system(size: 18 * fontScale))
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                Text("\nPriest: A reading from the holy Gospel according to...")
                    .font(.system(size: 18 * fontScale))
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                Text("People: Glory to you, O Lord.\n")
                    .bold()
                    .font(.system(size: 18 * fontScale))
                    .font(.headline)
                    .multilineTextAlignment(.leading)
            }
        }
    }
    
    private func readingEnd(for title: String) -> some View {
        Group {
            if settings.isNewCatMode {
                if title.contains("Reading"){
                        Text("\nReader: The Word of the Lord")
                        .font(.system(size: 18 * fontScale))
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                        Text("Response: Thanks be to God")
                            .bold()
                            .font(.system(size: 18 * fontScale))
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                    } else if title == "Gospel" {
                        Text("\nPriest: The Gospel of the Lord.")
                            .font(.system(size: 18 * fontScale))
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                        Text("People: Praise to you, Lord Jesus Christ.")
                            .bold()
                            .font(.system(size: 18 * fontScale))
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                    }
            }
        }
    }
}

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

