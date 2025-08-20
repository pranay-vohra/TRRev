//
//  WelcomeUIView.swift
//  TRRev
//
//  Created by pranay vohra on 20/08/25.
//

import SwiftUI

struct WelcomeUIView: View {
    var body: some View {
        VStack( spacing: 10) {
            
            // Progress bar
            ProgressView(value: 0)
                .accentColor(.orange)
                .padding(.top,35)
                .padding(.horizontal)
            
            Spacer()
            
            Image("logo")
                .resizable()
                .frame(width: 400, height: 300)
            
            
            Spacer()
            
            // Title
            Text("Welcome")
                .font(.title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Subtitle
            Text("Lets get you registered")
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, -5)
            
            NavigationLink(destination: RegistrationUIView()) {
                Image(systemName: "arrow.right")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(red: 113/255, green: 128/255, blue: 255/255))
                    .frame(width: 70, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .shadow(radius: 5)
                    )
               }
            .padding(.top)
               
               Spacer().frame(height: 50)
        }
    }
}

#Preview {
    WelcomeUIView()
}
