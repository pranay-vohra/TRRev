//
//  DashboardViewModel.swift
//  TRRev
//
//  Created by pranay vohra on 20/08/25.
//

import Foundation

class DashboardViewModel:ObservableObject{
    // Published properties matching Info struct
     @Published var name: String = ""
     @Published var nameUpper: String = ""
     @Published var phoneNo: String = ""
     @Published var whatsappNo: String = ""
     @Published var countryCode: String = ""
     @Published var email: String = ""
     @Published var gender: String = ""
     @Published var age: String = ""
     @Published var ageUnit: String = ""
     
     // Loading and error states
     @Published var isLoading: Bool = false
     @Published var errorMessage: String?
     @Published var isDataLoaded: Bool = false
     
     // Get user data and update published properties
     func getUser() async throws {
         // Update loading state on main thread
         await MainActor.run {
             self.isLoading = true
             self.errorMessage = nil
         }
         
         // Get user ID from UserDefaults
         guard let userID = UserDefaults.getUserRegistrationID() else {
             await MainActor.run {
                 self.errorMessage = "User is not registered or ID not found"
                 self.isLoading = false
             }
             throw DashboardError.userNotRegistered
         }
         
         // Construct endpoint with proper GUID format
         let endpoint = "http://199.192.26.248:8000/sap/opu/odata/sap/ZCDS_C_TEST_REGISTER_NEW_CDS/ZCDS_C_TEST_REGISTER_NEW(guid'\(userID)')"
         
         guard let url = URL(string: endpoint) else {
             await MainActor.run {
                 self.errorMessage = "Invalid URL"
                 self.isLoading = false
             }
             throw DashboardError.invalidURL
         }
         
         // Create request with headers
         var request = URLRequest(url: url)
         request.httpMethod = "GET"
         request.setValue("application/json", forHTTPHeaderField: "Accept")
         request.setValue("X", forHTTPHeaderField: "X-Requested-With")
         
         do {
             let (data, response) = try await URLSession.shared.data(for: request)
             
             // Print raw response for debugging
             if let jsonString = String(data: data, encoding: .utf8) {
                 print("Raw JSON Response:")
                 print(jsonString)
             }
             
             // Check HTTP response status
             if let httpResponse = response as? HTTPURLResponse {
                 print("HTTP Status Code: \(httpResponse.statusCode)")
                 guard 200...299 ~= httpResponse.statusCode else {
                     await MainActor.run {
                         self.errorMessage = "HTTP error with status code: \(httpResponse.statusCode)"
                         self.isLoading = false
                     }
                     throw DashboardError.httpError(httpResponse.statusCode)
                 }
             }
             
             // Decode the OData response
             let odataResponse = try JSONDecoder().decode(ODataResponse.self, from: data)
             let userInfo = odataResponse.d
             
             print("Successfully fetched user: \(userInfo)")
             
             // Update published properties on main thread
             await MainActor.run {
                 self.updateProperties(with: userInfo)
                 self.isLoading = false
                 self.isDataLoaded = true
                 self.errorMessage = nil
             }
             
         } catch let decodingError as DecodingError {
             print("Decoding Error Details:")
             var errorDesc = "Decoding error occurred"
             
             switch decodingError {
             case .keyNotFound(let key, let context):
                 errorDesc = "Missing key: \(key)"
                 print("Missing key: \(key) at path: \(context.codingPath)")
             case .typeMismatch(let type, let context):
                 errorDesc = "Type mismatch for: \(type)"
                 print("Type mismatch for type: \(type) at path: \(context.codingPath)")
             case .valueNotFound(let type, let context):
                 errorDesc = "Value not found for: \(type)"
                 print("Value not found for type: \(type) at path: \(context.codingPath)")
             case .dataCorrupted(let context):
                 errorDesc = "Data corrupted"
                 print("Data corrupted at path: \(context.codingPath)")
             @unknown default:
                 errorDesc = "Unknown decoding error"
                 print("Unknown decoding error: \(decodingError)")
             }
             
             await MainActor.run {
                 self.errorMessage = errorDesc
                 self.isLoading = false
             }
             
             throw DashboardError.decodingError(decodingError)
             
         } catch {
             await MainActor.run {
                 self.errorMessage = "Network error: \(error.localizedDescription)"
                 self.isLoading = false
             }
             throw DashboardError.networkError(error)
         }
     }
     
     // Helper function to update published properties
     private func updateProperties(with userInfo: InfoResponse) {
         self.name = userInfo.name
         self.nameUpper = userInfo.nameUpper
         self.phoneNo = userInfo.phoneNo
         self.whatsappNo = userInfo.whatsappNo
         self.countryCode = userInfo.countryCode
         self.email = userInfo.email
         self.gender = userInfo.gender
         self.age = userInfo.age
         self.ageUnit = userInfo.ageUnit
     }
     
     // Convenience method to get Info struct from current properties
     func getCurrentInfo() -> Info {
         return Info(
             name: name,
             nameUpper: nameUpper,
             phoneNo: phoneNo,
             whatsappNo: whatsappNo,
             countryCode: countryCode,
             email: email,
             gender: gender,
             age: age,
             ageUnit: ageUnit
         )
     }
     
     // Method to clear all data (useful for logout)
     func clearUserData() {
         name = ""
         nameUpper = ""
         phoneNo = ""
         whatsappNo = ""
         countryCode = ""
         email = ""
         gender = ""
         age = ""
         ageUnit = ""
         isDataLoaded = false
         errorMessage = nil
     }
     
     // Method to refresh user data
     func refreshUserData() {
         Task {
             do {
                 try await getUser()
             } catch {
                 print("Failed to refresh user data: \(error)")
             }
         }
     }
 }

 // Enhanced DashboardError enum
 enum DashboardError: Error, LocalizedError {
     case invalidURL
     case userNotRegistered
     case decodingError(DecodingError)
     case httpError(Int)
     case networkError(Error)
     case invalidData
     
     var errorDescription: String? {
         switch self {
         case .invalidURL:
             return "Invalid URL"
         case .userNotRegistered:
             return "User is not registered or ID not found"
         case .decodingError(let error):
             return "Decoding error: \(error.localizedDescription)"
         case .httpError(let statusCode):
             return "HTTP error with status code: \(statusCode)"
         case .networkError(let error):
             return "Network error: \(error.localizedDescription)"
         case .invalidData:
             return "Invalid data received from server"
         }
     }
 }
