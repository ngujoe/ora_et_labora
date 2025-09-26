//
//  reflectView.swift
//  DailyBread
//
//  Created by Joseph Nguyen on 9/10/25.
//

import SwiftUI

struct ReflectView: View {
    // This will receive the selected questions, but we need to
    // modify its type to be a binding to save a state
    @Binding var selectedQuestions: [String]
    @Binding var notes: String // State for the notes TextEditor
    
    // A key for UserDefaults to save the notes
    private let notesKey = "ReflectionNotes"

    var body: some View {
        VStack {
            Text("Your Reflection")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom)

            // Section for selected questions
            Text("Selected Questions:")
                .font(.headline)
                .padding(.horizontal)
            
            if selectedQuestions.isEmpty {
                Text("No questions selected for reflection.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List {
                    ForEach(selectedQuestions, id: \.self) { question in
                        Text(question)
                            .padding(.vertical, 2)
                    }
                }
                .frame(maxHeight: 200) // Give the list a fixed height to make it scrollable
                .cornerRadius(10)
                .padding(.horizontal)
            }

            // Section for notes
            Text("Your Notes:")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)

            TextEditor(text: $notes)
                .frame(minHeight: 150) // Give the TextEditor a minimum height
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
                .padding(.horizontal)
                .padding(.bottom)

            Spacer() // Pushes content to the top
        }
        .onAppear {
            // Load notes from cache when the view appears
            loadNotes()
        }
        .onDisappear {
            // Save notes to cache when the view disappears
            saveNotes()
        }
    }

    // Function to load notes from UserDefaults
    private func loadNotes() {
        if let savedNotes = UserDefaults.standard.string(forKey: notesKey) {
            notes = savedNotes
        }
    }

    // Function to save notes to UserDefaults
    private func saveNotes() {
        UserDefaults.standard.set(notes, forKey: notesKey)
    }
}
