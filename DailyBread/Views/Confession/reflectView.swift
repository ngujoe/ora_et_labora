//
//  reflectView.swift
//  DailyBread
//
//  Created by Joseph Nguyen on 9/10/25.
//

import SwiftUI

struct ReflectView: View {
    @Binding var selectedQuestions: [String]
    @Binding var notes: String

    var body: some View {
        VStack {
            Text("Your Reflection")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom)

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
                .frame(maxHeight: 200)
                .cornerRadius(10)
                .padding(.horizontal)
            }

            Text("Your Notes:")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)

            TextEditor(text: $notes)
                .frame(minHeight: 150)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
                .padding(.horizontal)
                .padding(.bottom)

            Spacer()
        }
    }
}
