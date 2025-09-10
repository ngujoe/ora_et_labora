//
//  confessQuest.swift
//  DailyBread
//
//  Created by Joseph Nguyen on 9/9/25.
//

import SwiftUI

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

struct confessQuest: View {
    
    // State to hold all questions loaded from the JSON
    @State private var allQuestions: [QuestionItem] = []
    
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
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Confession Reflection")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            
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
                        ForEach(filteredQuestions) { item in
                            Text(item.question)
                                .padding(.vertical, 5)
                                .padding(.horizontal)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
            VStack{
                NavigationLink(destination: reflectView()){
                    Text("Reflect")
                }
            }
        }
        .navigationTitle("Confession")
        .onAppear {
            allQuestions = loadQuestions()
        }
    }
}

#Preview{
    confessQuest()
        .environmentObject(AppSettings())
}
