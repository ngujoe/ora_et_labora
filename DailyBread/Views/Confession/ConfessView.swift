//
//  ConfessView.swift
//  DailyBread
//
//  Created by Joseph Nguyen on 9/23/25.
//

import SwiftUI

struct ConfessView: View {

    // BINDING for the user's notes (sins) written in a previous view
    @Binding var notes: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                
                Text("Confession Guide")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 10)
                
                // --- Step 1: Greeting and Sign of the Cross ---
                ConfessionStep(
                    step: 1,
                    title: "Preparation & Greeting",
                    content: "Kneel down, make the Sign of the Cross, and say:"
                )
                Text("**You:** Bless me, Father, for I have sinned. It has been [Number of weeks/months/years] since my last Confession. These are my sins...")
                    .font(.body)
                
                // --- Step 2: Confess Sins (Using Notes) ---
                VStack(alignment: .leading, spacing: 8) {
                    ConfessionStepTitle(step: 2, title: "Confession of Sins")
                    
                    Text("Read the sins you have prepared:")
                        .font(.body)
                    
                    // Display the user's sins from the notes binding
                    ScrollView {
                            Text(notes)
                                .font(.body)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading) // Keeps the text aligned left
                                .frame(maxWidth: .infinity, alignment: .leading) // Forces it to the left edge
                                .padding(8) // Padding inside the scroll view for readability
                        }
                        // Set a fixed height for the ScrollView to enable internal scrolling
                        .frame(height: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        )
                        .padding(.horizontal, -4)

                    Text("End with: **I am sorry for these and all my sins.**")
                        .font(.body)
                }
                .padding(.horizontal)
                
                // --- Step 3: Advice and Penance ---
                ConfessionStep(
                    step: 3,
                    title: "Penance",
                    content: "Listen to the priest's advice, and then accept the penance he gives you. Say the Act of Contrition."
                )
                Text("**Act of Contrition:**\nMy God, I am sorry for my sins with all my heart. In choosing to do wrong and failing to do good, I have sinned against you whom I should love above all things.\n\nI firmly intend, with your help, to do penance, to sin no more, and to avoid whatever leads me to sin.\n\nOur Savior Jesus Christ suffered and died for us. In his name, my God, have mercy. Amen.")
                    .font(.body)
                ConfessionStep(
                    step: 4,
                    title: "Absolution",
                    content: "The priest will say a prayer of absolution."
                )
                Text("Priest: ...and I absolve you of your sins in the name of the Father, and of the Son, and of the Holy Spirit. (make the Sign of the Cross)")
                    .font(.body)
                Text("**You:** Amen.")
                    .font(.body)
                Text("Priest: Go in peace.")
                    .font(.body)
                Text("**You:** Thanks be to God.")
                    .font(.body)
            }
            .padding()
        }
    }
}

// Helper view for consistent step titles
struct ConfessionStepTitle: View {
    let step: Int
    let title: String
    
    var body: some View {
        HStack {
            Text("\(step).")
                .font(.headline)
                .foregroundColor(.blue)
            Text(title)
                .font(.headline)
        }
    }
}

// Helper view for consistent step formatting
struct ConfessionStep: View {
    let step: Int
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ConfessionStepTitle(step: step, title: title)
            Text(content)
                .padding(.leading, 20)
                .foregroundColor(.primary)
        }
        .padding(.horizontal)
    }
}
