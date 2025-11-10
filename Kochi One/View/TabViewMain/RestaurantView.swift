//
//  CafeViewFull.swift
//  Kochi One
//
//  Created by APPLE on 05/10/2025.
//


//
//  CafeView.swift
//  Kochi One
//
//  Created by APPLE on 01/10/2025.
//

import SwiftUI
import CoreLocation

// Main RestaurantView function that handles search integration
func RestaurantView(activeSheet: Binding<BottomBarView.SheetType?>, locationService: LocationService, restaurantService: RestaurantService, selectedRestaurantName: Binding<String?>) -> some View {
    RestaurantViewM(restaurantService: restaurantService, locationService: locationService, selectedRestaurantName: selectedRestaurantName)
}

// --- The original post template view ---
struct RestaurantViewFull: View {
    @State private var activeID: String?
    @Binding var showDetail: Bool
    let restaurant: Restaurant
    @ObservedObject var locationService: LocationService
   
    var body: some View {
        /// Remove the NavigationStack here, as IndividualTabView is already in a ScrollView
        VStack {
            HStack(alignment: .top, spacing: 12) {
                CachedAsyncImage(url: restaurant.logo?.url ?? "") { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 45, height: 45)
                        .clipShape(Circle())
                } placeholder: {
                    Circle()
                        .fill(.fill)
                        .frame(width: 45, height: 45)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        if !restaurant.name.isEmpty {
                            // 1. DATA LOADED: Show the actual restaurant name
                            Text(restaurant.name)
                                .font(.headline)
                                .lineLimit(1)
                        } else {
                            // 2. PLACEHOLDER: Show the rectangle when the name is not available
                            Rectangle()
                                .fill(.fill)
                                .frame(width: 150, height: 18) // Adjusted size
                                .clipShape(.rect(cornerRadius: 3))
                        }
                        Spacer()
                            .foregroundColor(.secondary)
                        Text(locationService.calculateDistance(to: restaurant))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Image(systemName: "location.north.line.fill")
                            .foregroundColor(.blue)
                            .rotationEffect(.degrees(locationService.calculateBearing(to: restaurant)))
//                        Text("Rating: \(String(format: "%.1f", restaurant.rating))")
//                            .font(.caption)
//                            .foregroundColor(.secondary)

                        
                    }
                    
                    Group {
                        if !restaurant.description.isEmpty {
                            // 1. DATA LOADED: Show the actual description text
                            Text(restaurant.description)
                                .font(.subheadline)
                                .lineLimit(4) // Limit to match the visual space of the 4 lines of placeholders
                        } else {
                            // 2. PLACEHOLDER: Show the repeated rectangles when description is not available
                            VStack(alignment: .leading, spacing: 5) { // Added alignment .leading for text-like justification
                                ForEach(1...4, id: \.self) { index in
                                    Rectangle()
                                        .fill(.fill)
                                        .frame(height: 5)
                                        // Make the last line shorter to simulate real text
                                        .padding(.trailing, index == 4 ? 50 : 0)
                                }
                            }
                        }
                    } // The Group is optional here, but makes the intent clear
                    .padding(.top, 10)    // <--- MODIFIERS MOVED AND APPLIED HERE
                    .padding(.bottom, 20)
                    

                    
                    let config = ImageViewerConfig(height: 100, cornerRadius: 10, spacing: 5)
                    
                    ImageViewer(config: config) {
                        ForEach(restaurant.coverImages.prefix(4), id: \.url) { coverImage in
                            CachedAsyncImage(url: coverImage.url) { image in
                                image
                                    .resizable()
                            } placeholder: {
                                Rectangle()
                                    .fill(.gray.opacity(0.4))
                                    .overlay {
                                        ProgressView()
                                            .tint(.blue)
                                            .scaleEffect(0.7)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    }
                            }
                            .containerValue(\.activeViewID, coverImage.url)
                        }
                    } overlay: {
                        OverlayViewCafe(activeID: activeID, restaurant: restaurant)
                    } updates: { isPresented, activeID in
                        self.activeID = activeID?.base as? String
                    }
                    
                    HStack {
                                            // 1. Message/Comment Button
                                            Button {
                                                print("Comment button tapped")
                                                // Action: Maybe set a sheet to show comments, or navigate
                                                // activeSheet = .commentsSheet // Example action
                                            } label: {
                                                Image(systemName: "message")
                                            }
                                            
                                            Spacer()
                                            
                                            // 2. Repost Button
                                            Button {
                                                print("Repost button tapped")
                                                // Action: Initiate repost logic
                                            } label: {
                                                Image(systemName: "arrow.trianglehead.bottomleft.capsulepath.clockwise")
                                            }

                                            Spacer()
                                            
                                            // 3. Like/Heart Button
                                            Button {
                                                print("Like button tapped")
                                                // Action: Toggle the liked state for this post
                                            } label: {
                                                Image(systemName: "suit.heart")
                                            }

                                            Spacer()
                                            
                                            // 4. Share Button
                                            Button {
                                                print("Share button tapped")
                                                // Action: Show a native share sheet
                                            } label: {
                                                Image(systemName: "square.and.arrow.up")
                                            }
                                        }
                                        .foregroundStyle(.primary.secondary)
                                        .padding(.top, 10)
                }
                .padding(.top, 10)
            }
            .padding([.leading, .trailing], 15) // Only apply horizontal padding to content

            Spacer(minLength: 0)
        }
        .contentShape(Rectangle()) // Makes the whole post area tappable
    }
}

// --- NEW Wrapper View to display multiple posts ---
struct RestaurantViewM: View {
    @ObservedObject var restaurantService: RestaurantService
    @ObservedObject var locationService: LocationService
    @State private var showDetail = false
    @State private var selectedRestaurant: Restaurant?
    @Binding var selectedRestaurantName: String?
    
    var body: some View {
        // Show list view
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) { // spacing: 0 to remove extra padding between the RestaurantViewFull content
                if restaurantService.isLoading {
                    VStack {
                        ProgressView("Loading restaurants...")
                            .padding()
                    }
                } else if restaurantService.restaurants.isEmpty {
                    VStack {
                        Text("No restaurants available")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                } else {
                    ForEach(restaurantService.restaurants.filter { $0.isActive && $0.restaurantType?.lowercased() == "restaurant" }) { restaurant in
                        RestaurantViewFull(showDetail: $showDetail, restaurant: restaurant, locationService: locationService)
                            .onTapGesture {
                                print("Restaurant tapped: \(restaurant.name)")
                                selectedRestaurant = restaurant
                                selectedRestaurantName = restaurant.name
                                showDetail = true
                            }
                        
                        // Add a subtle separator between posts
                        Divider()
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showDetail) {
            if let restaurant = selectedRestaurant {
                RestaurantDetailView(restaurant: restaurant, locationService: locationService) {
                    // Back button action
                    showDetail = false
                    selectedRestaurant = nil
                    selectedRestaurantName = nil
                }
            }
        }
        .onAppear {
            // Only fetch if we don't have data yet
            if restaurantService.restaurants.isEmpty && !restaurantService.isLoading {
                restaurantService.fetchRestaurants()
            }
        }
        .alert("Error", isPresented: .constant(restaurantService.errorMessage != nil)) {
            Button("OK") {
                restaurantService.errorMessage = nil
            }
        } message: {
            Text(restaurantService.errorMessage ?? "")
        }
        .alert("Location Permission Required", isPresented: .constant(locationService.authorizationStatus == .denied)) {
            Button("Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable location access in Settings to see distances to restaurants.")
        }
    }
}


struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @ObservedObject var locationService: LocationService
    let onBack: () -> Void
    
    var body: some View {
        VStack {
            // Header with back button
            HStack {
                Button(action: onBack) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                .foregroundColor(.blue)
                
                Spacer()
            }
            .padding()
            
            // Restaurant content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Restaurant logo and basic info
                    HStack(alignment: .top, spacing: 12) {
                        CachedAsyncImage(url: restaurant.logo?.url ?? "") { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                        } placeholder: {
                            Circle()
                                .fill(.fill)
                                .frame(width: 60, height: 60)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(restaurant.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            HStack {
                                Text(locationService.calculateDistance(to: restaurant))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Image(systemName: "location.north.line.fill")
                                    .foregroundColor(.blue)
                                    .rotationEffect(.degrees(locationService.calculateBearing(to: restaurant)))
                            }
                            
                            if !restaurant.description.isEmpty {
                                Text(restaurant.description)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    // Cover images
                    if !restaurant.coverImages.isEmpty {
                        let config = ImageViewerConfig(height: 200, cornerRadius: 15, spacing: 8)
                        
                        ImageViewer(config: config) {
                            ForEach(restaurant.coverImages, id: \.url) { coverImage in
                                CachedAsyncImage(url: coverImage.url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Rectangle()
                                        .fill(.gray.opacity(0.4))
                                        .overlay {
                                            ProgressView()
                                                .tint(.blue)
                                                .scaleEffect(0.7)
                                        }
                                }
                                .containerValue(\.activeViewID, coverImage.url)
                            }
                        } overlay: {
                            OverlayViewRestaurant(activeID: nil, restaurant: restaurant)
                        } updates: { isPresented, activeID in
                            // Handle image viewer updates if needed
                        }
                    }
                    
                    // Additional restaurant details can be added here
                    VStack(alignment: .leading, spacing: 12) {
                        // Address details
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "location")
                                    .foregroundColor(.blue)
                                Text("\(restaurant.address.street), \(restaurant.address.city)")
                                    .font(.body)
                            }
                            
                            Text("\(restaurant.address.state) \(restaurant.address.zipCode), \(restaurant.address.country)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading, 24)
                        }
                        
                        // Contact details
                        if !restaurant.contact.phone.isEmpty {
                            HStack {
                                Image(systemName: "phone")
                                    .foregroundColor(.blue)
                                Text(restaurant.contact.phone)
                                    .font(.body)
                            }
                        }
                        
                        if !restaurant.contact.email.isEmpty {
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(.blue)
                                Text(restaurant.contact.email)
                                    .font(.body)
                            }
                        }
                        
                        if let website = restaurant.contact.website, !website.isEmpty {
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(.blue)
                                Text(website)
                                    .font(.body)
                            }
                        }
                    }
                    .padding(.top)
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
    }
}

/// Overlay View
struct OverlayViewRestaurant: View {
    var activeID: String?
    let restaurant: Restaurant
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundStyle(.white.secondary)
                    .padding(10)
                    .contentShape(.rect)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay {
                if let coverImage = restaurant.coverImages.first(where: { $0.url == activeID }) {
                    Text(coverImage.alt ?? restaurant.name)
                        .font(.callout)
                        .foregroundStyle(.white)
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(15)
    }
}

