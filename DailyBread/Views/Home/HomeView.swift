//
//  HomeView.swift
//  DailyBread
//
//  Created by Joe on 7/29/25.
//

import SwiftUI
import Foundation

let screenWidth = UIScreen.main.bounds.width * 0.9
let screenHeightButton = UIScreen.main.bounds.width * 0.2

struct HomeView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack{
            ZStack{
                VStack{
                    Text("3rd Sunday in Ordinary Time")
                        .bold()
                        .font(.title2)
                    Text("Saine Anne the Mother of Mary")
                }
            }
            .padding()
            // TODO : FIGURE THIS THING OUT AND WHY THE BACKGROUND NOT WORKING
            //.background(colorScheme == .dark ? Color.white.opacity(0.8) : Color.gray.opacity(0.5))
            .frame(width: .infinity, height: screenHeightButton)
            ScrollView{
                DailyReadingsView()
            }
        }
    }
}

#Preview{
    HomeView()
}
