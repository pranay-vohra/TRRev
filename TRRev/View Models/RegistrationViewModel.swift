//
//  RegistrationViewModel.swift
//  TRRev
//
//  Created by pranay vohra on 20/08/25.
//

import Foundation


class RegistrationViewModel: ObservableObject{
    @Published var info = Info.empty
    
    
    func makePOSTRequest() async throws -> Info {
        let endpoint = "http://199.192.26.248:8000/sap/opu/odata/sap/ZCDS_C_TEST_REGISTER_NEW_CDS/ZCDS_C_TEST_REGISTER_NEW"
        
        guard let url = URL(string: endpoint) else {
            throw RegistrationError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("X", forHTTPHeaderField: "X-Requested-With")
        
        do {
            request.httpBody = try JSONEncoder().encode(info) // Your existing Info object
        } catch {
            throw RegistrationError.encodingError(error)
        }
        
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
                    throw RegistrationError.httpError(httpResponse.statusCode)
                }
            }
            
            // Decode the full response (including ID)
            let odataResponse = try JSONDecoder().decode(ODataResponse.self, from: data)
            let fullResponse = odataResponse.d
            
            // Save the ID to UserDefaults
            UserDefaults.saveUserRegistrationID(fullResponse.id)
            
            print("Success: \(fullResponse)")
            print("User ID saved to UserDefaults: \(fullResponse.id)")
            
            // Return the Info object (without ID) for your UI
            return fullResponse.toInfo()
            
        } catch let decodingError as DecodingError {
            print("Decoding Error Details:")
            switch decodingError {
            case .keyNotFound(let key, let context):
                print("Missing key: \(key) at path: \(context.codingPath)")
                print("Debug description: \(context.debugDescription)")
            case .typeMismatch(let type, let context):
                print("Type mismatch for type: \(type) at path: \(context.codingPath)")
                print("Debug description: \(context.debugDescription)")
            case .valueNotFound(let type, let context):
                print("Value not found for type: \(type) at path: \(context.codingPath)")
                print("Debug description: \(context.debugDescription)")
            case .dataCorrupted(let context):
                print("Data corrupted at path: \(context.codingPath)")
                print("Debug description: \(context.debugDescription)")
            @unknown default:
                print("Unknown decoding error: \(decodingError)")
            }
            throw RegistrationError.decodingError(decodingError)
        } catch {
            throw RegistrationError.networkError(error)
        }
    }

}

enum RegistrationError: Error, LocalizedError {
    case invalidURL
    case encodingError(Error)
    case decodingError(DecodingError)
    case httpError(Int)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .encodingError(let error):
            return "Encoding error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
