//
//  RegistrationUIView.swift
//  TRRev
//
//  Created by pranay vohra on 20/08/25.
//

import SwiftUI

struct RegistrationUIView: View {
    @EnvironmentObject var authViewModel:AuthViewModel
    @StateObject var viewModel = RegistrationViewModel()
    @State private var isSameAsPhone: Bool = true
    @State private var isLoading = false
    let countries = [
        "IN", "US", "UK", "CA", "AU", "NZ", "FR", "DE", "IT", "ES", "CN", "JP", "KR",
        "BR", "MX", "ZA", "RU", "SG", "AE", "SA", "NG", "KE"
    ]

    var isNameValid: Bool {
        !viewModel.info.name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var isEmailValid: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: viewModel.info.email)
    }
    
    var isPhoneValid: Bool {
        let phoneRegEx = "^[0-9]{7,15}$"
        let phonePred = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        return phonePred.evaluate(with: viewModel.info.phoneNo)
    }
    
    var isWhatsappValid: Bool {
        if isSameAsPhone { return true }
        let phoneRegEx = "^[0-9]{7,15}$"
        let phonePred = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        return phonePred.evaluate(with: viewModel.info.whatsappNo)
    }
    
    var isAgeValid: Bool {
        if let ageInt = Int(viewModel.info.age) {
            return ageInt > 0 && ageInt < 120
        }
        return false
    }
    
    var isFormValid: Bool {
        isNameValid && isEmailValid && isPhoneValid && isWhatsappValid && isAgeValid && !viewModel.info.gender.isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Progress bar
            ProgressView(value: 0.5)
                .accentColor(.orange)
                .padding(.horizontal)
            
            // Title
            Text("Basic Details")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Subtitle
            Text("Feel free to fill your details")
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, -5)
            
            ScrollView {
                // Input fields
                VStack(alignment: .leading, spacing: 30) {
                    Text("Full Name")
                        .font(.subheadline)
                        .padding(.top, 10)
                    
                    TextField("Name", text: $viewModel.info.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.top, -20)
                    
                    Text("Email ID")
                        .font(.subheadline)
                    TextField("Email ID", text: $viewModel.info.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(.top, -20)
                    
                    Toggle("Phone number is same as WhatsApp", isOn: $isSameAsPhone)
                        .onChange(of: isSameAsPhone) { newValue in
                            if newValue {
                                viewModel.info.whatsappNo = viewModel.info.phoneNo
                            }
                        }
                    
                    HStack {
                        Picker("Country Code", selection: $viewModel.info.countryCode) {
                            ForEach(countries, id: \.self) { country in
                                Text(country)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 80)
                        
                        VStack {
                            TextField("Phone Number", text: $viewModel.info.phoneNo)
                                .keyboardType(.phonePad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onChange(of: viewModel.info.phoneNo) { newValue in
                                    if isSameAsPhone {
                                        viewModel.info.whatsappNo = newValue
                                    }
                                }
                            
                            if !isSameAsPhone {
                                TextField("WhatsApp Number", text: $viewModel.info.whatsappNo)
                                    .keyboardType(.phonePad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }
                    }
                    .padding(.top, -20)
                    
                    Text("Gender")
                        .font(.subheadline)
                    HStack {
                        ForEach(["M", "F", "O"], id: \.self) { gender in
                            Button(action: {
                                // Fixed: Use consistent property name (lowercase 'g')
                                viewModel.info.gender = gender
                            }) {
                                if(gender=="O"){
                                    Text("Others")
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 20)
                                        .background(
                                            Capsule()
                                                .stroke(Color.orange, lineWidth: 1)
                                                .background(
                                                    Capsule()
                                                        .fill(viewModel.info.gender == gender ? Color.orange : Color.clear)
                                                )
                                        )
                                        .foregroundColor(viewModel.info.gender == gender ? .white : .orange)
                                }else{
                                    Text(gender)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 20)
                                        .background(
                                            Capsule()
                                                .stroke(Color.orange, lineWidth: 1)
                                                .background(
                                                    Capsule()
                                                        .fill(viewModel.info.gender == gender ? Color.orange : Color.clear)
                                                )
                                        )
                                        .foregroundColor(viewModel.info.gender == gender ? .white : .orange)
                                }
                            }
                        }
                    }
                    .padding(.top, -20)
                    
                    Text("Age")
                        .font(.subheadline)
                    TextField("Age", text: $viewModel.info.age)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.top, -20)
                }
                .padding(.horizontal)
                
                if isLoading {
                    ProgressView("Registering...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }else{
                    
                    // Next Button
                    Button {
                        viewModel.info.nameUpper =  viewModel.info.name.uppercased()
                        Task {
                            do {
                                let result = try await viewModel.makePOSTRequest()
                                // Handle successful response on main thread
                                await MainActor.run {
                                    // Update UI here
                                    print("Received response: \(result)")
                                    // You might want to navigate to next screen here
                                }
                            } catch {
                                // Handle error on main thread
                                await MainActor.run {
                                    print("Error: \(error)")
                                    // Show error alert to user
                                    // You might want to set an @State variable to show an alert
                                }
                            }
                        }
                        
                        isLoading = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isLoading = false
                            authViewModel.authStatus = .registered
                        }
                    } label: {
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
                    .disabled(!isFormValid)
                    .opacity(isFormValid ? 1 : 0.5)
                    .padding(.top, 30)
                    .padding(.bottom, 30)
                }
                    
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    RegistrationUIView()
}
