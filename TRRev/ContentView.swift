//
//  ContentView.swift
//  TRRev
//
//  Created by pranay vohra on 19/08/25.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject var authViewModel:AuthViewModel
    var body: some View {
        if(authViewModel.authStatus == .registered){
            DashBoardUIView()
        }else{
            NavigationView {
                WelcomeUIView()
            }
        }
    }
}

#Preview {
    ContentView()
}
