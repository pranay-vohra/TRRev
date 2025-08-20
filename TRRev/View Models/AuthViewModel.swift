//
//  AuthViewModel.swift
//  TRRev
//
//  Created by pranay vohra on 20/08/25.
//

import Foundation
enum AuthStatus {
    case unregistered
    case registered
}

class AuthViewModel: ObservableObject{
    @Published var authStatus = AuthStatus.unregistered
    
    init() {
        if UserDefaults.isUserRegistered() {
            self.authStatus = .registered
        } else {
            self.authStatus = .unregistered
        }
    }
}
