//
//  TRRevApp.swift
//  TRRev
//
//  Created by pranay vohra on 19/08/25.
//

import SwiftUI

@main
struct TRRevApp: App {
    @StateObject var authViewModel = AuthViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
        
    }
}
