//
//  SubmitFB.swift
//  DailyBread
//
//  Created by Joe on 8/27/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct FeedbackView: View {
    @Binding var isPresented: Bool

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var feedback: String = ""
    @State private var selection = "General Inquiry"
    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var viewMode: ViewMode = .form

    enum ViewMode { case form, thankYou }

    let fbOptions = ["General Inquiry", "Question", "Feature Request", "Report an Issue"]

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Group {
                switch viewMode {
                case .form:
                    formView
                case .thankYou:
                    thankYouView
                }
            }
            .navigationTitle("Send Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .alert("Submission Status", isPresented: $showAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
    }

    private var formView: some View {
        Form {
            Section("Type of Feedback") {
                Picker("Category", selection: $selection) {
                    ForEach(fbOptions, id: \.self) { Text($0) }
                }
                .pickerStyle(.menu)
            }

            Section("Your Details (optional)") {
                TextField("Name", text: $name)
                    .textContentType(.name)
                    .autocorrectionDisabled()
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
            }

            Section("Message") {
                TextEditor(text: $feedback)
                    .frame(minHeight: 120)
            }

            Section {
                Button {
                    submitFeedback()
                    AnalyticsManager.shared.logEvent(name: "button_tapped", parameters: [
                        "button_name": "feedback_submit_button",
                        "view_name": "settings_view"
                    ])
                } label: {
                    if isSubmitting {
                        HStack {
                            ProgressView().progressViewStyle(.circular)
                            Text("Submitting…")
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Text("Submit")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(feedback.isEmpty ? Color.secondary : Color.blue)
                    }
                }
                .disabled(feedback.isEmpty || isSubmitting)
            }
        }
    }

    private var thankYouView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(Color.blue)

            VStack(spacing: 8) {
                Text("Thank You!")
                    .font(.title.bold())
                Text("We appreciate you taking the time\nto help us improve.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button("Submit Another") { resetForm() }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    private func submitFeedback() {
        isSubmitting = true
        let db = Firestore.firestore()
        let feedbackData: [String: Any] = [
            "name": name,
            "email": email,
            "feedback": feedback,
            "timestamp": FieldValue.serverTimestamp()
        ]
        db.collection(selection).addDocument(data: feedbackData) { error in
            self.isSubmitting = false
            if let error = error {
                self.alertMessage = "Failed to submit. Please try again."
                self.showAlert = true
                print("Feedback error: \(error)")
            } else {
                withAnimation { self.viewMode = .thankYou }
            }
        }
    }

    private func resetForm() {
        name = ""
        email = ""
        feedback = ""
        selection = "General Inquiry"
        withAnimation { viewMode = .form }
    }
}
