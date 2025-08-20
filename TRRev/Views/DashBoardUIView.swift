//
//  DashBoardUIView.swift
//  TRRev
//
//  Created by pranay vohra on 20/08/25.
//

import SwiftUI

struct DashBoardUIView: View {
    @EnvironmentObject var authViewModel:AuthViewModel
    @StateObject private var viewModel = DashboardViewModel()
    @State private var currentBannerIndex = 0
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack{
            
            ZStack {
                RoundedRectangle(cornerRadius: 200)
                    .fill(Color(red: 240/255, green: 244/255, blue: 255/255))
                    .frame(width: 500, height: 500)
                    .rotationEffect(.degrees(45))
                    .position(x: 150, y:50)
                
                
                RoundedRectangle(cornerRadius: 200)
                    .fill(Color(red: 0.85, green: 0.87, blue: 0.97))
                    .frame(width: 380, height: 500)
                    .rotationEffect(.degrees(35))
                    .position(x: 180, y:-10)
                
                VStack(alignment: .leading, spacing: 20) {
                    if viewModel.isLoading {
                        ProgressView("Loading user data...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let errorMessage = viewModel.errorMessage {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.red)
                            
                            Text("Error")
                                .font(.headline)
                            
                            Text(errorMessage)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                            
                            Button("Retry") {
                                viewModel.refreshUserData()
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                    } else{
                        // Custom header
                        headerView
                        
                        // Main content
                        ScrollView {
                            VStack(spacing: 20) {
                                // Search Bar
                                searchBarView
                                
                                // Banner Carousel
                                bannerCarouselView
                                
                                // Features Section
                                featuresSection
                            }
                        }
                        .padding(.horizontal)
                    }
     
                }
                .onAppear {
                    // Load user data when view appears
                    if !viewModel.isDataLoaded {
                        viewModel.refreshUserData()
                    }
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack(spacing: 10) {
            
            // User profile navigation
            userProfileButton
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Hello,")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Text("\(viewModel.nameUpper)!") //add user name here
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Button{
                
            }label: {
                ZStack {
                    Image(systemName: "bell.badge")
                        .resizable()
                        .frame(width: 22, height: 25)
                        .foregroundStyle(.black)
                }
            }
        
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var userProfileButton: some View {
            NavigationLink {
                Form {
                    Section {
                        Text("Doctor ID: \(String(UserDefaults.getUserRegistrationID() ?? ""))")
                            .font(.body)
                            .foregroundColor(.primary)
                        Text("Name: \(viewModel.name)")
                            .font(.body)
                            .foregroundColor(.primary)
                        Text("Phone Number: \(viewModel.phoneNo)")
                            .font(.body)
                            .foregroundColor(.primary)
                        Text("Email: \(viewModel.email)")
                            .font(.body)
                            .foregroundColor(.primary)
                        Text("Gender: \(viewModel.gender)")
                            .font(.body)
                            .foregroundColor(.primary)
                        Text("Age: \(viewModel.age) \(viewModel.ageUnit)")
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    
                    Button("SignOut",role: .destructive){
                        UserDefaults.clearRegistrationData()
                        authViewModel.authStatus = .unregistered
                    }
                }
                .navigationTitle("Registered Information")
                .navigationBarTitleDisplayMode(.inline)
            } label: {
                ZStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 42, height: 42)
                        .foregroundStyle(.black)
                }
            }
        }
        
        // MARK: - Search Bar View
        
        private var searchBarView: some View {
            HStack {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(Color(red: 113/255, green: 128/255, blue: 255/255))
                
                TextField("Search...", text: .constant(""))
                    .foregroundColor(.primary)
                
                Spacer(minLength: 0)
                
            }
            .frame(height: 50)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    
    // MARK: - Banner Carousel
    private var bannerCarouselView: some View {
        VStack(spacing: 15) {
            TabView(selection: $currentBannerIndex) {
                ForEach(0..<bannerData.count, id: \.self) { index in
                    BannerCard(banner: bannerData[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 160)
            .onReceive(timer) { _ in
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentBannerIndex = (currentBannerIndex + 1) % bannerData.count
                }
            }
            
            // Custom page indicator
            HStack(spacing: 8) {
                ForEach(0..<bannerData.count, id: \.self) { index in
                    Circle()
                        .fill(currentBannerIndex == index ? Color.orange : Color.gray.opacity(0.5))
                        .frame(width: 8, height: 8)
                }
            }
        }
    }
    
    // MARK: - Features Section
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("At your Fingertip")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 3), spacing: 20) {
                ForEach(featureData, id: \.title) { feature in
                    FeatureButton(
                        title: feature.title,
                        icon: feature.icon,
                        isHighlighted: feature.isHighlighted
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Banner Card Component

struct BannerCard: View {
    let banner: BannerInfo
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(banner.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Text(banner.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.leading)
            }
            .padding(.leading, 20)
            
            Spacer()
            
            // Illustration area
            HStack(spacing: -10) {
                Image(systemName: "person.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 50, height: 50)
                    )
                
                Image(systemName: "stethoscope")
                    .font(.system(size: 35))
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 55, height: 55)
                    )
            }
            .padding(.trailing, 20)
            
            // Close button
            VStack {
                Button(action: {}) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 24, height: 24)
                        )
                }
                Spacer()
            }
            .padding(.trailing, 15)
            .padding(.top, 15)
        }
        .frame(height: 140)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 113/255, green: 128/255, blue: 255/255), Color.purple.opacity(0.8)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

// MARK: - Feature Button Component

struct FeatureButton: View {
    var title: String
    var icon: String
    var isHighlighted: Bool = false
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(isHighlighted ? .white : Color(red: 113/255, green: 128/255, blue: 255/255))
                
                Text(title)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(isHighlighted ? .white : .primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, minHeight: 90)
            .background(isHighlighted ? Color.orange : Color(.systemGray6))
            .cornerRadius(15)
        }
    }
}

// MARK: - Data Models

struct BannerInfo {
    let title: String
    let subtitle: String
}

struct FeatureInfo {
    let title: String
    let icon: String
    let isHighlighted: Bool
}

// MARK: - Sample Data

let bannerData: [BannerInfo] = [
    BannerInfo(title: "Stay Safe\nStay Healthy!", subtitle: "An apple a day\nkeeps the\ndoctor away."),
    BannerInfo(title: "Health First!", subtitle: "Prevention is\nbetter than\ncure."),
    BannerInfo(title: "Wellness Matters", subtitle: "Take care of\nyour body\ntoday.")
]

let featureData: [FeatureInfo] = [
    FeatureInfo(title: "Scan", icon: "qrcode", isHighlighted: true),
    FeatureInfo(title: "Vaccine", icon: "cross.vial", isHighlighted: false),
    FeatureInfo(title: "My Bookings", icon: "calendar", isHighlighted: false),
    FeatureInfo(title: "Clinic", icon: "building.2", isHighlighted: false),
    FeatureInfo(title: "Ambulance", icon: "truck.box", isHighlighted: false),
    FeatureInfo(title: "Nurse", icon: "person.fill.checkmark", isHighlighted: false)
]

#Preview {
    DashBoardUIView()
}
