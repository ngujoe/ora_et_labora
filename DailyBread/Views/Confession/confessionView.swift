//
//  confessionView.swift
//  DailyBread
//
//  Created by Joseph Nguyen on 9/23/25.
//

import SwiftUI

struct ThreePartProcessView: View {
    // Persisted so in-progress confession survives app close
    @AppStorage("confessionStep")  private var currentStep: Int = 0
    @AppStorage("confessionNotes") private var notes: String = ""
    @AppStorage("confessionQuestionsJSON") private var questionsJSON: String = "[]"

    @State private var selectedQuestions: [String] = []
    @State private var showCompletion = false

    @AppStorage("lastConfessionDateInterval") private var lastConfessionDateInterval: Double = 0

    private let totalSteps = 3
    private let stepLabels = ["Review", "Reflect", "Confess"]

    private var lastConfessionDate: Date? {
        lastConfessionDateInterval > 0 ? Date(timeIntervalSince1970: lastConfessionDateInterval) : nil
    }

    var body: some View {
        VStack(spacing: 0) {

            if showCompletion {
                completionView
            } else {
                // Last confession date banner
                if let last = lastConfessionDate {
                    HStack {
                        Image(systemName: "calendar.badge.checkmark")
                            .foregroundStyle(.green)
                        Text("Last confession: \(last.formatted(.dateTime.month(.wide).day().year()))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Step indicator
                VStack(spacing: 10) {
                    HStack(spacing: 0) {
                        ForEach(0..<totalSteps, id: \.self) { step in
                            HStack(spacing: 0) {
                                ZStack {
                                    Circle()
                                        .fill(step <= currentStep ? Color.blue : Color(.tertiarySystemBackground))
                                        .frame(width: 36, height: 36)
                                    if step < currentStep {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(.white)
                                    } else {
                                        Text("\(step + 1)")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundStyle(step == currentStep ? .white : .secondary)
                                    }
                                }
                                if step < totalSteps - 1 {
                                    Rectangle()
                                        .fill(step < currentStep ? Color.blue : Color(.tertiarySystemBackground))
                                        .frame(height: 2)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                    }

                    HStack(spacing: 0) {
                        ForEach(0..<totalSteps, id: \.self) { step in
                            Text(stepLabels[step])
                                .font(.caption.weight(step == currentStep ? .semibold : .regular))
                                .foregroundStyle(step == currentStep ? Color.blue : .secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, lastConfessionDate == nil ? 20 : 10)
                .padding(.bottom, 16)

                Divider()

                // Step content
                Group {
                    if currentStep == 0 {
                        ReviewQuestionsView(selectedQuestions: $selectedQuestions)
                    } else if currentStep == 1 {
                        ReflectView(selectedQuestions: $selectedQuestions, notes: $notes)
                    } else {
                        ConfessView(notes: $notes)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Divider()

                // Navigation buttons
                HStack(spacing: 12) {
                    if currentStep > 0 {
                        Button {
                            withAnimation(.spring(response: 0.3)) { currentStep -= 1 }
                        } label: {
                            Label("Previous", systemImage: "chevron.left")
                                .font(.body.weight(.medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.bordered)
                        .tint(.secondary)
                    }

                    if currentStep < totalSteps - 1 {
                        Button {
                            withAnimation(.spring(response: 0.3)) { currentStep += 1 }
                        } label: {
                            HStack {
                                Text("Next")
                                Image(systemName: "chevron.right")
                            }
                            .font(.body.weight(.medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        // Final step — complete confession
                        Button {
                            withAnimation(.spring(response: 0.4)) {
                                lastConfessionDateInterval = Date.now.timeIntervalSince1970
                                // Clear all persisted confession state
                                selectedQuestions = []
                                questionsJSON = "[]"
                                notes = ""
                                currentStep = 0
                                // Remove legacy key that ReflectView previously wrote separately
                                UserDefaults.standard.removeObject(forKey: "ReflectionNotes")
                                showCompletion = true
                            }
                        } label: {
                            Text("Complete")
                                .font(.body.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .onAppear {
            // Restore selected questions from persisted JSON
            if let data = questionsJSON.data(using: .utf8),
               let decoded = try? JSONDecoder().decode([String].self, from: data) {
                selectedQuestions = decoded
            }
        }
        .onChange(of: selectedQuestions) { _, newValue in
            // Keep JSON store in sync whenever selections change
            if let data = try? JSONEncoder().encode(newValue),
               let str = String(data: data, encoding: .utf8) {
                questionsJSON = str
            }
        }
    }

    // MARK: - Completion screen

    private var completionView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.green)

                VStack(spacing: 8) {
                    Text("Confession Complete")
                        .font(.title2.bold())
                }

                if let last = lastConfessionDate {
                    Text(last.formatted(.dateTime.weekday(.wide).month(.wide).day().year()))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.green)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 40)

            Spacer()

            Button {
                withAnimation(.spring(response: 0.3)) { showCompletion = false }
            } label: {
                Text("Begin Again")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
