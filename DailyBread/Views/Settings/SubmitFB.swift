//
//  SubmitFB.swift
//  DailyBread
//
//  Created by Joe on 8/27/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct FeedbackFormWrapper: View {
    @Binding var showFeedbackForm: Bool // Use a binding to control the parent's state

    var body: some View {
        VStack {
            Spacer()
            // The FeedbackView is centered in the wrapper
            FeedbackView(isPresented: $showFeedbackForm)
                .frame(maxWidth: .infinity) // Adjust size as needed
                .padding(5)
            Spacer()
        }
        .background(Color.black.opacity(0.4).ignoresSafeArea())
        .onTapGesture {
            // Tapping outside the form closes it
            withAnimation {
                self.showFeedbackForm = false
            }
        }
    }
}

struct FeedbackView: View {
    @Binding var isPresented: Bool
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var feedback: String = ""
    @State private var isSubmitting: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @Environment(\.colorScheme) var colorScheme

    // An enum to manage the different view states
    enum ViewMode {
        case form, thankYou
    }

    @State private var viewMode: ViewMode = .form

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        self.isPresented = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                }
            }
            .padding(.top)
            
            // Switch between the form and thank you view
            switch viewMode {
            case .form:
                feedbackForm
            case .thankYou:
                thankYouView
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20.0)
                .fill(colorScheme == .dark ? .gray : .white)
                .shadow(radius: 10.0)
                .padding(10)
        )
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Submission Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    // A separate view for the feedback form
    @State private var selection = "General Inquiry"
    let fbOptions = ["General Inquiry", "Question", "Feature Request","Report an Issue"]
    
    private var feedbackForm: some View {
        VStack {
            Text("We'd love to hear from you!")
                .font(.headline)
                .padding(.bottom)
            VStack {
                Text("Type of Feedback:")
                        Picker("Select a paint color", selection: $selection) {
                            ForEach(fbOptions, id: \.self) {
                                Text($0)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray)
                                .opacity(0.5)
                        )
                    }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray)
                        .opacity(0.1)
                )

            TextField("Name (optional)", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.words)
                .padding(.horizontal)

            TextField("Email (optional)", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding(.horizontal)

            TextEditor(text: $feedback)
                .frame(height: 150)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(.horizontal)
            
            Button(action: {
                submitFeedback()
            }) {
                if isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                } else {
                    Text("Submit")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(feedback.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
            }
            .disabled(feedback.isEmpty || isSubmitting)
            .padding()
        }
    }

    // A separate view for the thank you message
    private var thankYouView: some View {
        VStack {
            Text("Thank You for Your Feedback! 🙏")
                .font(.title2)
                .padding(.bottom, 20)
            
            Text("We appreciate you taking the time to help us improve.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 30)

            Button(action: {
                resetForm()
            }) {
                Text("Submit New Feedback")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }

    private func submitFeedback() {
        self.isSubmitting = true
        let db = Firestore.firestore()
        
        let feedbackData: [String: Any] = [
            "name": name,
            "email": email,
            "feedback": feedback,
            "timestamp": FieldValue.serverTimestamp()
        ]
        //db.collection("feedback") OLD CREATE FOR SPECIFCALLLY FEEDBACK
        db.collection(selection).addDocument(data: feedbackData) { error in
            self.isSubmitting = false
            if let error = error {
                print("Error adding document: \(error)")
                self.alertMessage = "Failed to submit feedback. Please try again."
                self.showAlert = true
            } else {
                print("Document successfully written!")
                // Show the thank you view instead of closing the form
                withAnimation {
                    self.viewMode = .thankYou
                    selection = "General Inquiry" // Resets feedback selection
                }
            }
        }
    }

    private func resetForm() {
        // Reset all form fields and switch back to the form view
        name = ""
        email = ""
        feedback = ""
        withAnimation {
            self.viewMode = .form
        }
    }
}
