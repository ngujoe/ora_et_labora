//
//  confessQuest.swift
//  DailyBread
//
//  Created by Joseph Nguyen on 9/9/25.
//

import SwiftUI

struct ReviewQuestionsView: View {
    
    private let selectedQuestionsKey = "SavedSelectedQuestions"
    
    // State to hold all questions loaded from the JSON
    @State private var allQuestions: [QuestionItem] = []
    
    @Binding var selectedQuestions: [String]
    
    // State to track which category buttons are active
    @State private var selectedCategories: Set<String> = []
    
    // A computed property to get the questions that match the selected categories
    var filteredQuestions: [QuestionItem] {
        if selectedCategories.isEmpty {
            return []
        } else {
            return allQuestions.filter { question in
                !question.categories.filter { selectedCategories.contains($0) }.isEmpty
            }
        }
    }
    
    func loadQuestions() -> [QuestionItem] {
        guard let url = Bundle.main.url(forResource: "confessionQuestions", withExtension: "json") else {
            print("Failed to locate confessionQuestions.json in bundle.")
            return []
        }
        guard let data = try? Data(contentsOf: url) else {
            print("Failed to load confessionQuestions.json from bundle.")
            return []
        }
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode([QuestionItem].self, from: data)
            return decodedData
        } catch {
            print("Failed to decode confessionQuestions.json: \(error.localizedDescription)")
            return []
        }
    }
    
    func removeAllSelected() {
            selectedQuestions.removeAll()
        }
    
    func saveSelectedQuestions() {
            if let encoded = try? JSONEncoder().encode(selectedQuestions) {
                UserDefaults.standard.set(encoded, forKey: selectedQuestionsKey)
            }
        }
    
    func loadSelectedQuestions() {
            if let savedData = UserDefaults.standard.data(forKey: selectedQuestionsKey) {
                if let decodedQuestions = try? JSONDecoder().decode([String].self, from: savedData) {
                    selectedQuestions = decodedQuestions
                    return
                }
            }
            // If no data is found, initialize with an empty array
            selectedQuestions = []
        }
    
    var body: some View {
        VStack(spacing: 0) {
            /*
            Text("Confession Reflection")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            */
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Category.allCases, id: \.self) { category in
                        Button(action: {
                            if selectedCategories.contains(category.rawValue) {
                                selectedCategories.remove(category.rawValue)
                            } else {
                                selectedCategories.insert(category.rawValue)
                            }
                        }) {
                            Text(category.rawValue.capitalized.replacingOccurrences(of: "_", with: " "))
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(selectedCategories.contains(category.rawValue) ? Color.blue : Color.gray.opacity(0.3))
                                .foregroundColor(selectedCategories.contains(category.rawValue) ? .white : .black)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding()
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if filteredQuestions.isEmpty && !selectedCategories.isEmpty {
                        Text("No questions found for the selected categories.")
                            .foregroundColor(.secondary)
                            .padding()
                    } else if selectedCategories.isEmpty {
                        Text("Please select one or more categories above to see the questions.")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        Button(action: removeAllSelected) {
                            Text("Remove All Selected")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedQuestions.isEmpty ? Color.gray : Color.red.opacity(0.9))
                                .cornerRadius(8)
                        }
                        .disabled(selectedQuestions.isEmpty)
                        ForEach(filteredQuestions) { item in
                            Button(action: {
                                // Toggle the selection state of the question
                                if selectedQuestions.contains(item.question) {
                                    selectedQuestions.removeAll(where: { $0 == item.question })
                                } else {
                                    selectedQuestions.append(item.question)
                                }
                            }) {
                                Text(item.question)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .multilineTextAlignment(.center)
                                    .padding(.vertical, 10) // Increased vertical padding for better spacing
                                    .background(selectedQuestions.contains(item.question) ? Color.blue.opacity(0.8) : Color.gray.opacity(0.1))
                                    .foregroundColor(selectedQuestions.contains(item.question) ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            allQuestions = loadQuestions()
            loadSelectedQuestions() // Load saved questions when the view appears
        }
        .onDisappear {
            saveSelectedQuestions() // Save questions when the view disappears
        }
    }
}

// Make sure your data model matches the JSON, as corrected in a previous response.
struct QuestionItem: Codable, Identifiable {
    let id = UUID()
    let question: String
    let categories: [String]
    
    enum CodingKeys: String, CodingKey {
        case question
        case categories
    }
}

// Define an enum for the categories to make filtering robust
enum Category: String, CaseIterable {
    case universal = "universal"
    case student = "student"
    case parent = "parent"
    case adult = "adult"
    case spousePartner = "spouse_partner"
    case employeeProfessional = "employee_professional"
}
