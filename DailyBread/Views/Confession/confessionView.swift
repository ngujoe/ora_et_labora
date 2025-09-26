//
//  confessionView.swift
//  DailyBread
//
//  Created by Joseph Nguyen on 9/23/25.
//

import SwiftUI

struct ThreePartProcessView: View {
    @State private var currentStep: Int = 0
    @State private var selectedQuestions: [String] = []
    @State private var notes: String = ""

    private let totalSteps = 3
    
    private var progress: Double {
        Double(currentStep + 1) / Double(totalSteps)
    }

    var body: some View {
        VStack(spacing: 20) {
            // Progress Bar
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .padding(.horizontal, 20)
            
            // Step Titles
            HStack(spacing: 0) {
                Text("Review")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(currentStep == 0 ? .blue : .gray)
                
                Text("Reflect")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(currentStep == 1 ? .blue : .gray)
                
                Text("Confess")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(currentStep == 2 ? .blue : .gray)
            }
            .padding(.horizontal)
            
            // Main Content View based on currentStep
            VStack {
                if currentStep == 0 {
                    ReviewQuestionsView(selectedQuestions: $selectedQuestions)
                } else if currentStep == 1 {
                    ReflectView(selectedQuestions: $selectedQuestions, notes: $notes)
                } else {
                    ConfessView(notes: $notes)
                }
            }
            // Navigation Buttons
            HStack(spacing: 20) {
                if currentStep > 0 {
                    Button(action: {
                        currentStep -= 1
                    }) {
                        Text("Previous")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray)
                            .cornerRadius(10)
                    }
                }
                
                if currentStep < totalSteps - 1 {
                    Button(action: {
                        currentStep += 1
                    }) {
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}
