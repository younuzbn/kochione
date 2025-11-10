//
//  EatsView.swift
//  Kochi One
//
//  Created by APPLE on 01/10/2025.
//

import SwiftUI
import CoreLocation

// Main EatsView function that handles search integration
func EatsView(activeSheet: Binding<BottomBarView.SheetType?>, locationService: LocationService, restaurantService: RestaurantService, selectedRestaurantName: Binding<String?>) -> some View {
    EatsViewM(restaurantService: restaurantService, locationService: locationService, selectedRestaurantName: selectedRestaurantName)
}

// --- The original post template view ---
struct EatsViewFull: View {
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
                        OverlayViewEats(activeID: activeID, restaurant: restaurant)
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
struct EatsViewM: View {
    @ObservedObject var restaurantService: RestaurantService
    @ObservedObject var locationService: LocationService
    @State private var showDetail = false
    @State private var selectedRestaurant: Restaurant?
    @Binding var selectedRestaurantName: String?
    @State private var selectedCategory: String = "All"
    @StateObject private var eatsMapState = EatsMapState.shared
    
    // Hardcoded categories - always available even if API fails
    let availableCategories: [String] = [
        "All",
        "Restaurants",
        "Cafes",
        "Pubs & Bars",
        "Juice & Shake",
        "Food Truck",
        "Bakeries & Desserts",
        "Buffet & Fine Dining"
    ]
    
    // Filter restaurants based on selected category using API restaurantType
    // Use @State to hold filtered results - updated via onChange to prevent recomputation on every view update
    @State private var filteredRestaurants: [Restaurant] = []
    
    private func computeFilteredRestaurants() -> [Restaurant] {
        // Filter active restaurants first (most efficient)
        let activeRestaurants = restaurantService.restaurants.filter { $0.isActive }
        
        // If "All" selected, return all active restaurants
        guard selectedCategory != "All" else {
            return activeRestaurants
        }
        
        let categoryLower = selectedCategory.lowercased()
        
        // Pre-compile keywords for better performance
        let keywords: [String]
        switch categoryLower {
        case "restaurants":
            keywords = ["restaurant", "fine dining", "multicuisine", "family restaurant"]
        case "cafes":
            keywords = ["cafe", "coffee", "cowork", "chill spot"]
        case "pubs & bars":
            keywords = ["pub", "bar", "nightlife", "live music", "cocktail", "lounge"]
        case "juice & shake":
            keywords = ["juice", "shake", "smoothie", "mocktail", "fresh juice"]
        case "food truck":
            keywords = ["food truck", "truck", "mobile food", "street vendor", "night eats", "local street"]
        case "bakeries & desserts":
            keywords = ["bakery", "dessert", "cake", "pastry", "ice cream", "sweet"]
        case "buffet & fine dining":
            keywords = ["buffet", "fine dining", "luxury", "hotel"]
        default:
            // Fallback: exact match
            return activeRestaurants.filter { restaurant in
                restaurant.restaurantType?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == categoryLower
            }
        }
        
        // Filter with pre-compiled keywords
        return activeRestaurants.filter { restaurant in
            guard let restaurantType = restaurant.restaurantType?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) else {
                return false
            }
            
            // Special handling for cafes to avoid matching "cafeteria"
            if categoryLower == "cafes" {
                return matchesCategory(restaurantType, keywords: keywords) && !restaurantType.contains("cafeteria")
            }
            
            return matchesCategory(restaurantType, keywords: keywords)
        }
    }
    
    // Helper function to update filtered restaurants
    private func updateFilteredRestaurants() {
        filteredRestaurants = computeFilteredRestaurants()
    }
    
    // Helper function to check if restaurantType matches any keywords
    private func matchesCategory(_ restaurantType: String, keywords: [String]) -> Bool {
        return keywords.contains { keyword in
            restaurantType.contains(keyword)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Category Switcher (similar to TransitView) - always show
            CustomCategoryControl(
                selection: $selectedCategory,
                options: availableCategories
            )
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .padding(.bottom, 12) // Add more space below category tab
            
            // Show list view
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) { // spacing: 0 to remove extra padding between the EatsViewFull content
                    if restaurantService.isLoading {
                        VStack {
                            ProgressView("Loading restaurants...")
                                .padding()
                        }
                    } else if filteredRestaurants.isEmpty {
                        VStack {
                            Text("No restaurants available")
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    } else {
                        ForEach(filteredRestaurants) { restaurant in
                            EatsViewFull(showDetail: $showDetail, restaurant: restaurant, locationService: locationService)
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
        }
        .fullScreenCover(isPresented: $showDetail) {
            if let restaurant = selectedRestaurant {
                EatsDetailView(restaurant: restaurant, locationService: locationService) {
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
            // Initialize filtered restaurants
            updateFilteredRestaurants()
            // Sync initial category with map state
            eatsMapState.selectedCategory = selectedCategory
        }
        .onChange(of: selectedCategory) { oldValue, newValue in
            // Recompute when category changes
            updateFilteredRestaurants()
            // Update map state for annotation filtering
            eatsMapState.selectedCategory = newValue
        }
        .onChange(of: restaurantService.restaurants.count) { oldValue, newValue in
            // Recompute when restaurants change
            if newValue != oldValue {
                updateFilteredRestaurants()
            }
        }
        .onChange(of: restaurantService.isLoading) { oldValue, newValue in
            // Recompute when loading completes
            if !newValue && oldValue {
                updateFilteredRestaurants()
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


struct EatsDetailView: View {
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
                            OverlayViewEats(activeID: nil, restaurant: restaurant)
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
struct OverlayViewEats: View {
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

// MARK: - Custom Category Control (similar to TransitView's CustomSegmentedControl)
struct CustomCategoryControl: View {
    @Binding var selection: String
    let options: [String]
    @Namespace private var animation
    @Environment(\.colorScheme) var colorScheme
    
    // Get icon for each category
    private func icon(for option: String) -> String {
        let lowercased = option.lowercased()
        switch lowercased {
        case "all":
            return "square.grid.2x2.fill"
        case "restaurants":
            return "fork.knife"
        case "cafes":
            return "cup.and.saucer.fill"
        case "pubs & bars":
            return "wineglass.fill"
        case "juice & shake":
            return "takeoutbag.and.cup.and.straw.fill"
        case "food truck":
            return "car.fill"
        case "bakeries & desserts":
            return "birthday.cake.fill"
        case "buffet & fine dining":
            return "sparkles"
        default:
            return "circle.fill"
        }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selection = option
                        }
                    } label: {
                        ZStack {
                            // Selected background with pill shape - black in light mode, white in dark mode
                            if selection == option {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(colorScheme == .dark ? Color.white : Color.black)
                                    .shadow(color: colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                    .matchedGeometryEffect(id: "selectedCategory", in: animation)
                            }
                            
                            // Content: Icon + Text for selected, Icon only for unselected
                            HStack(spacing: 6) {
                                Image(systemName: icon(for: option))
                                    .font(.system(size: 16, weight: selection == option ? .semibold : .medium))
                                    .foregroundStyle(selection == option ? (colorScheme == .dark ? .black : .white) : .primary)
                                
                                if selection == option {
                                    Text(option)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(colorScheme == .dark ? .black : .white)
                                }
                            }
                            .padding(.horizontal, selection == option ? 18 : 12)
                            .padding(.vertical, 10)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemGray6))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

