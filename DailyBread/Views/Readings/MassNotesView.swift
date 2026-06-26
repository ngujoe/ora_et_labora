//
//  MassNotesView.swift
//  DailyBread
//
//  Created by Joe on 6/25/26.
//

import SwiftUI

// MARK: - Data model

struct NoteData: Codable {
    var title: String
    var body: String

    var isEmpty: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Notes storage

class NotesManager {
    static let shared = NotesManager()
    private init() {}

    private var notesDirectory: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("MassNotes")
    }

    private func fileURL(for date: Date) -> URL {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd"
        return notesDirectory.appendingPathComponent("note-\(f.string(from: date)).json")
    }

    func save(note: NoteData, for date: Date) {
        try? FileManager.default.createDirectory(at: notesDirectory, withIntermediateDirectories: true)
        let url = fileURL(for: date)
        if note.isEmpty {
            try? FileManager.default.removeItem(at: url)
        } else {
            let data = try? JSONEncoder().encode(note)
            try? data?.write(to: url, options: .atomic)
        }
    }

    func load(for date: Date) -> NoteData? {
        let url = fileURL(for: date)
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url) else { return nil }

        // Try JSON first (new format)
        if let note = try? JSONDecoder().decode(NoteData.self, from: data) {
            return note
        }
        // Fallback: old plain-text format
        if let text = String(data: data, encoding: .utf8) {
            return NoteData(title: "", body: text)
        }
        return nil
    }

    func hasNote(for date: Date) -> Bool {
        FileManager.default.fileExists(atPath: fileURL(for: date).path)
    }

    func allSavedDates() -> [Date] {
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: notesDirectory, includingPropertiesForKeys: nil
        ) else { return [] }
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd"
        return files.compactMap { url in
            guard url.pathExtension == "json" else { return nil }
            let stem = url.deletingPathExtension().lastPathComponent
            guard stem.hasPrefix("note-"),
                  let date = f.date(from: String(stem.dropFirst(5))),
                  let note = load(for: date),
                  !note.isEmpty else { return nil }
            return date
        }
    }
}

// MARK: - Focus state

private enum NoteField { case title, body }

// MARK: - Notes editor

struct MassNotesView: View {
    let date: Date
    /// True when presented as a `.sheet` — shows a nav-bar Done to dismiss.
    /// False when pushed via NavigationLink — back button handles navigation.
    var isSheet: Bool = false

    @State private var noteTitle = ""
    @State private var noteBody = ""
    @FocusState private var focused: NoteField?
    @Environment(\.dismiss) var dismiss

    private var dateTitle: String {
        date.formatted(.dateTime.weekday(.wide).month(.wide).day().year())
    }

    var body: some View {
        VStack(spacing: 0) {
            // Title field
            TextField("Title (optional)", text: $noteTitle)
                .font(.title3.weight(.semibold))
                .focused($focused, equals: .title)
                .onSubmit { focused = .body }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 14)

            Divider()
                .padding(.horizontal, 20)

            // Body editor
            ZStack(alignment: .topLeading) {
                if noteBody.isEmpty {
                    Text("Tap to write your notes…")
                        .foregroundStyle(.tertiary)
                        .font(.body)
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $noteBody)
                    .font(.body)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                    .focused($focused, equals: .body)
                    .scrollContentBackground(.hidden)
                    .onChange(of: noteBody, autoContinueBullet)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(dateTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isSheet {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        saveNote()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }

            ToolbarItemGroup(placement: .keyboard) {
                Button {
                    insertBullet()
                } label: {
                    Label("Bullet", systemImage: "list.bullet")
                }
                .disabled(focused != .body)

                Spacer()

                Button("Done") {
                    focused = nil
                }
            }
        }
        .onAppear {
            let saved = NotesManager.shared.load(for: date)
            noteTitle = saved?.title ?? ""
            noteBody  = saved?.body  ?? ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                focused = .body
            }
        }
        .onDisappear {
            saveNote()
        }
    }

    private func saveNote() {
        NotesManager.shared.save(
            note: NoteData(title: noteTitle, body: noteBody),
            for: date
        )
    }

    private func insertBullet() {
        let endsWithNewline = noteBody.hasSuffix("\n") || noteBody.isEmpty
        noteBody += endsWithNewline ? "• " : "\n• "
    }

    private func autoContinueBullet(oldValue: String, newValue: String) {
        guard newValue.count == oldValue.count + 1, newValue.hasSuffix("\n") else { return }
        let lines = oldValue.components(separatedBy: "\n")
        if let last = lines.last, last.hasPrefix("• "), last != "• " {
            noteBody = newValue + "• "
        }
    }
}

// MARK: - Saved notes list (shown in Settings)

struct SavedNotesListView: View {
    @State private var groupedNotes: [(month: String, dates: [Date])] = []

    var body: some View {
        Group {
            if groupedNotes.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "note.text")
                        .font(.system(size: 52))
                        .foregroundStyle(.quaternary)
                    Text("No Saved Notes")
                        .font(.title3.weight(.semibold))
                    Text("Tap the notes icon on the Readings page to write notes during Mass.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                List {
                    ForEach(groupedNotes, id: \.month) { group in
                        Section(group.month) {
                            ForEach(group.dates, id: \.self) { date in
                                NavigationLink {
                                    MassNotesView(date: date)
                                } label: {
                                    noteRow(for: date)
                                }
                            }
                            .onDelete { offsets in
                                offsets.forEach {
                                    NotesManager.shared.save(
                                        note: NoteData(title: "", body: ""),
                                        for: group.dates[$0]
                                    )
                                }
                                reload()
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Mass Notes")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { reload() }
    }

    @ViewBuilder
    private func noteRow(for date: Date) -> some View {
        let note = NotesManager.shared.load(for: date)
        VStack(alignment: .leading, spacing: 4) {
            Text(date, style: .date)
                .font(.headline)

            if let title = note?.title, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            } else if let preview = firstLine(note?.body) {
                Text(preview)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }

    private func reload() {
        let allDates = NotesManager.shared.allSavedDates().sorted().reversed()

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        var result: [(month: String, dates: [Date])] = []
        var seen: [String: Int] = [:]

        for date in allDates {
            let key = formatter.string(from: date)
            if let idx = seen[key] {
                result[idx].dates.append(date)
            } else {
                seen[key] = result.count
                result.append((month: key, dates: [date]))
            }
        }
        groupedNotes = result
    }

    private func firstLine(_ text: String?) -> String? {
        text?
            .components(separatedBy: "\n")
            .first { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }
}

#Preview {
    NavigationStack {
        MassNotesView(date: .now, isSheet: true)
    }
    .environmentObject(AppSettings())
}
