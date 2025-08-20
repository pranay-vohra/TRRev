//
//  userDefaults.swift
//  TRRev
//
//  Created by pranay vohra on 20/08/25.
//

import Foundation
// UserDefaults helper extension
extension UserDefaults {
    // Keys for storing data
    private enum Keys {
        static let userRegistrationID = "userRegistrationID"
        static let isUserRegistered = "isUserRegistered"
    }
    
    // Save user registration ID
    static func saveUserRegistrationID(_ id: String) {
        UserDefaults.standard.set(id, forKey: Keys.userRegistrationID)
        UserDefaults.standard.set(true, forKey: Keys.isUserRegistered)
        UserDefaults.standard.synchronize()
    }
    
    // Get user registration ID
    static func getUserRegistrationID() -> String? {
        return UserDefaults.standard.string(forKey: Keys.userRegistrationID)
    }
    
    // Check if user is registered
    static func isUserRegistered() -> Bool {
        return UserDefaults.standard.bool(forKey: Keys.isUserRegistered)
    }
    
    // Clear registration data (for logout or reset)
    static func clearRegistrationData() {
        UserDefaults.standard.removeObject(forKey: Keys.userRegistrationID)
        UserDefaults.standard.removeObject(forKey: Keys.isUserRegistered)
        UserDefaults.standard.synchronize()
    }
}
