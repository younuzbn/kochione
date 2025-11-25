//
//  EatsView.swift
//  Kochi One
//
//  Created by APPLE on 01/10/2025.
//

import SwiftUI
import CoreLocation

// Map App Types
enum MapApp: String, Identifiable {
    case appleMaps = "Apple Maps"
    case googleMaps = "Google Maps"
    case waze = "Waze"
    
    var id: String { rawValue }
    
    var urlScheme: String {
        switch self {
        case .appleMaps:
            return "http://maps.apple.com/"
        case .googleMaps:
            return "comgooglemaps://"
        case .waze:
            return "waze://"
        }
    }
    
    var icon: String {
        switch self {
        case .appleMaps:
            return "map.fill"
        case .googleMaps:
            return "map.fill"
        case .waze:
            return "map.fill"
        }
    }
    
    // Check if the map app is available on the device
    static func availableApps() -> [MapApp] {
        var available: [MapApp] = []
        
        // Apple Maps is always available on iOS
        available.append(.appleMaps)
        
        // Check Google Maps
        if let url = URL(string: "comgooglemaps://") {
            if UIApplication.shared.canOpenURL(url) {
                available.append(.googleMaps)
            }
        }
        
        // Check Waze
        if let url = URL(string: "waze://") {
            if UIApplication.shared.canOpenURL(url) {
                available.append(.waze)
            }
        }
        
        return available
    }
    
    // Generate URL for navigation with coordinates and business name
    func navigationURL(latitude: Double, longitude: Double, businessName: String? = nil) -> URL? {
        switch self {
        case .appleMaps:
            // Apple Maps supports q parameter with label
            if let name = businessName, !name.isEmpty {
                let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
                return URL(string: "http://maps.apple.com/?daddr=\(latitude),\(longitude)&q=\(encodedName)&dirflg=d")
            } else {
                return URL(string: "http://maps.apple.com/?daddr=\(latitude),\(longitude)&dirflg=d")
            }
        case .googleMaps:
            // Google Maps: Use daddr for navigation (not q which just shows location)
            // For business name, we can append it to coordinates with + separator
            if let name = businessName, !name.isEmpty {
                let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
                // Format: daddr=latitude,longitude+label for navigation with label
                return URL(string: "comgooglemaps://?daddr=\(latitude),\(longitude)+\(encodedName)&directionsmode=driving")
            } else {
                return URL(string: "comgooglemaps://?daddr=\(latitude),\(longitude)&directionsmode=driving")
            }
        case .waze:
            // Waze doesn't support labels in URL scheme, but we can try adding it as a note
            // Note: Waze URL scheme doesn't officially support business names
            return URL(string: "waze://?ll=\(latitude),\(longitude)&navigate=yes")
        }
    }
}

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
    @ObservedObject private var favouritesManager = FavouritesManager.shared
    @State private var showMapPicker = false
    @State private var showCallDialog = false
    @State private var showShareDialog = false
    @State private var heartScale: CGFloat = 1.0
    @State private var expandedImageURL: String? = nil
   
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
                    

                    
                    // Image viewer with expandable images
                    if let expandedURL = expandedImageURL {
                        // Show expanded image - height of two rows (2 × 100px + 5px spacing = 205px)
                        CachedAsyncImage(url: expandedURL) { image in
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
                        .frame(height: 205) // 2 rows × 100px + 5px spacing
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                expandedImageURL = nil
                            }
                        }
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        // Show all 4 images in grid
                        let config = ImageViewerConfig(height: 100, cornerRadius: 10, spacing: 5)
                        let coverImagesArray = Array(restaurant.coverImages.prefix(4))
                        
                        ImageViewer(config: config) {
                            ForEach(0..<coverImagesArray.count, id: \.self) { index in
                                let coverImage = coverImagesArray[index]
                                Button {
                                    // Directly use the index to get the correct image URL
                                    let tappedURL = coverImagesArray[index].url
                                    print("Tapped image at index \(index): \(tappedURL)")
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        expandedImageURL = tappedURL
                                    }
                                } label: {
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
                                }
                                .buttonStyle(.plain)
                                .containerValue(\.activeViewID, coverImage.url)
                            }
                        } overlay: {
                            OverlayViewEats(activeID: activeID, restaurant: restaurant)
                        } updates: { isPresented, activeID in
                            self.activeID = activeID?.base as? String
                        }
                    }
                    
                    HStack {
                                            // 1. Call Button
                                            Button {
                                                print("Call button tapped")
                                                showCallDialog = true
                                            } label: {
                                                Image(systemName: "phone")
                                            }
                                            .confirmationDialog("Call \(restaurant.name)?", isPresented: $showCallDialog, titleVisibility: .visible) {
                                                Button("Call") {
                                                    // Action: Make a phone call to the restaurant
                                                    let phoneNumber = restaurant.contact.phone
                                                    guard !phoneNumber.isEmpty else {
                                                        print("Phone number is empty")
                                                        return
                                                    }
                                                    
                                                    // Clean phone number: remove spaces, dashes, parentheses, etc., but keep + for international
                                                    let cleanedNumber = phoneNumber
                                                        .replacingOccurrences(of: " ", with: "")
                                                        .replacingOccurrences(of: "-", with: "")
                                                        .replacingOccurrences(of: "(", with: "")
                                                        .replacingOccurrences(of: ")", with: "")
                                                        .replacingOccurrences(of: ".", with: "")
                                                    
                                                    if let phoneURL = URL(string: "tel://\(cleanedNumber)") {
                                                        if UIApplication.shared.canOpenURL(phoneURL) {
                                                            UIApplication.shared.open(phoneURL)
                                                        } else {
                                                            print("Cannot open phone URL: \(phoneURL)")
                                                        }
                                                    } else {
                                                        print("Invalid phone number format: \(cleanedNumber)")
                                                    }
                                                }
                                                Button("Cancel", role: .cancel) { }
                                            } message: {
                                                Text(restaurant.contact.phone.isEmpty ? "No phone number available" : restaurant.contact.phone)
                                            }
                                            
                                            Spacer()
                                            
                                            // 2. Navigation Button
                                            Button {
                                                print("Navigation button tapped")
                                                // Show map picker if multiple apps available, otherwise open directly
                                                let availableApps = MapApp.availableApps()
                                                if availableApps.count == 1, let app = availableApps.first {
                                                    // Only one app available, open directly
                                                    if let url = app.navigationURL(latitude: restaurant.location.latitude, longitude: restaurant.location.longitude, businessName: restaurant.name) {
                                                        UIApplication.shared.open(url)
                                                    }
                                                } else {
                                                    // Multiple apps available, show picker
                                                    showMapPicker = true
                                                }
                                            } label: {
                                                Image(systemName: "location")
                                            }
                                            .confirmationDialog("Choose Navigation App", isPresented: $showMapPicker, titleVisibility: .visible) {
                                                ForEach(MapApp.availableApps()) { app in
                                                    Button(app.rawValue) {
                                                        if let url = app.navigationURL(latitude: restaurant.location.latitude, longitude: restaurant.location.longitude, businessName: restaurant.name) {
                                                            UIApplication.shared.open(url)
                                                        }
                                                    }
                                                }
                                                Button("Cancel", role: .cancel) { }
                                            }

                                            Spacer()
                                            
                                            // 3. Like/Heart Button
                                            Button {
                                                // Toggle favourite with animation
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                                    heartScale = 1.3
                                                }
                                                
                                                // Toggle favourite
                                                favouritesManager.toggleFavourite(restaurantID: restaurant.id)
                                                
                                                // Reset scale after animation
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                                        heartScale = 1.0
                                                    }
                                                }
                                            } label: {
                                                Image(systemName: favouritesManager.isFavourite(restaurantID: restaurant.id) ? "suit.heart.fill" : "suit.heart")
                                                    .foregroundColor(favouritesManager.isFavourite(restaurantID: restaurant.id) ? .red : .primary)
                                                    .scaleEffect(heartScale)
                                            }

                                            Spacer()
                                            
                                            // 4. Share Button
                                            Button {
                                                print("Share button tapped")
                                                showShareDialog = true
                                            } label: {
                                                Image(systemName: "square.and.arrow.up")
                                            }
                                            .confirmationDialog("", isPresented: $showShareDialog, titleVisibility: .hidden) {
                                                Button("Share") {
                                                    // Action: Show a native share sheet
                                                    shareRestaurant()
                                                }
                                                
                                                Button("Report") {
                                                    // Action: Report the restaurant
                                                    print("Report restaurant: \(restaurant.name)")
                                                }
                                                
                                                if let website = restaurant.contact.website, !website.isEmpty {
                                                    Button("View Menu") {
                                                        // Action: Open restaurant menu/website
                                                        let urlString = website.hasPrefix("http") ? website : "https://\(website)"
                                                        if let url = URL(string: urlString) {
                                                            UIApplication.shared.open(url)
                                                        }
                                                    }
                                                }
                                                
                                                Button("Cancel", role: .cancel) { }
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
    
    // Share restaurant function with deep link
    private func shareRestaurant() {
        // Create deep link URL with properly encoded restaurant biz_id
        let encodedBizId = restaurant.bizId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? restaurant.bizId
        let deepLinkURL = "kochione://restaurant?biz_id=\(encodedBizId)"
        let shareText = "Check out \(restaurant.name)!\n\n\(restaurant.description)\n\nLocation: \(restaurant.address.street), \(restaurant.address.city)\n\n\(deepLinkURL)"
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController,
              let url = URL(string: deepLinkURL) else {
            return
        }
        
        let activityViewController = UIActivityViewController(
            activityItems: [shareText, url],
            applicationActivities: nil
        )
        
        // For iPad support
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = rootViewController.view
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        // Find the topmost view controller
        var topController = rootViewController
        while let presented = topController.presentedViewController {
            topController = presented
        }
        
        topController.present(activityViewController, animated: true)
    }
}

// --- NEW Wrapper View to display multiple posts ---
struct EatsViewM: View {
    @ObservedObject var restaurantService: RestaurantService
    @ObservedObject var locationService: LocationService
    @EnvironmentObject var deepLinkManager: DeepLinkManager
    @State private var showDetail = false
    @State private var selectedRestaurant: Restaurant?
    @Binding var selectedRestaurantName: String?
    @State private var selectedCategory: String = "All"
    @StateObject private var eatsMapState = EatsMapState.shared
    @State private var pendingRestaurantID: String? = nil
    
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
            
            // Check for pending deep link when view appears
            // Use a small delay to ensure the view is fully ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let pendingDeepLink = deepLinkManager.pendingDeepLink {
                    print("🔍 Found pending deep link on appear: \(pendingDeepLink.description)")
                    handleDeepLink(pendingDeepLink)
                }
            }
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
                // Check if there's a pending deep link restaurant ID when restaurants are loaded
                if let pendingID = pendingRestaurantID, !restaurantService.restaurants.isEmpty {
                    navigateToRestaurant(id: pendingID)
                    pendingRestaurantID = nil
                }
            }
        }
        .onChange(of: restaurantService.isLoading) { oldValue, newValue in
            // Recompute when loading completes
            if !newValue && oldValue {
                updateFilteredRestaurants()
                // Check if there's a pending deep link restaurant ID
                if let pendingID = pendingRestaurantID {
                    navigateToRestaurant(id: pendingID)
                    pendingRestaurantID = nil
                }
            }
        }
        .onChange(of: deepLinkManager.pendingDeepLink) { oldValue, newValue in
            // Handle deep link
            print("🔄 Deep link onChange triggered. Old: \(oldValue?.description ?? "nil"), New: \(newValue?.description ?? "nil")")
            if let deepLink = newValue {
                print("📱 Processing deep link: \(deepLink)")
                handleDeepLink(deepLink)
                // Don't clear immediately - let it be cleared after navigation succeeds
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
    
    // Handle deep link
    private func handleDeepLink(_ deepLink: DeepLinkType) {
        switch deepLink {
        case .restaurant(let id):
            navigateToRestaurant(id: id)
        case .unknown:
            break
        }
    }
    
    // Navigate to restaurant by ID
    private func navigateToRestaurant(id: String) {
        print("🔗 Navigating to restaurant with ID: \(id)")
        print("📊 Current restaurants count: \(restaurantService.restaurants.count)")
        print("📊 Is loading: \(restaurantService.isLoading)")
        
        // Try to find restaurant immediately
        if let restaurant = restaurantService.restaurants.first(where: { $0.id == id }) {
            print("✅ Found restaurant: \(restaurant.name)")
            selectedRestaurant = restaurant
            selectedRestaurantName = restaurant.name
            showDetail = true
            // Clear pending deep link after successful navigation
            deepLinkManager.pendingDeepLink = nil
            pendingRestaurantID = nil
        } else {
            print("⏳ Restaurant not found yet, storing ID: \(id)")
            print("📋 Available restaurant IDs: \(restaurantService.restaurants.map { $0.id }.prefix(5))")
            // Restaurant not found - store the ID and wait for restaurants to load
            pendingRestaurantID = id
            
            // If restaurants are empty and not loading, fetch them
            if restaurantService.restaurants.isEmpty && !restaurantService.isLoading {
                print("📥 Fetching restaurants...")
                restaurantService.fetchRestaurants()
            }
            
            // Also check periodically in case restaurants are already loading
            checkForRestaurantPeriodically(id: id)
        }
    }
    
    // Periodically check for restaurant until found or timeout
    private func checkForRestaurantPeriodically(id: String, attempts: Int = 0, maxAttempts: Int = 10) {
        guard attempts < maxAttempts else {
            print("Failed to find restaurant with ID: \(id) after \(maxAttempts) attempts")
            pendingRestaurantID = nil
            return
        }
        
        if let restaurant = restaurantService.restaurants.first(where: { $0.id == id }) {
            print("✅ Found restaurant in periodic check: \(restaurant.name)")
            selectedRestaurant = restaurant
            selectedRestaurantName = restaurant.name
            showDetail = true
            pendingRestaurantID = nil
            // Clear pending deep link after successful navigation
            deepLinkManager.pendingDeepLink = nil
        } else if !restaurantService.isLoading && restaurantService.restaurants.isEmpty {
            // Still loading, check again
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                checkForRestaurantPeriodically(id: id, attempts: attempts + 1, maxAttempts: maxAttempts)
            }
        } else if !restaurantService.isLoading {
            // Loading complete but restaurant not found
            print("Restaurant with ID \(id) not found in loaded restaurants")
            pendingRestaurantID = nil
        } else {
            // Still loading, check again
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                checkForRestaurantPeriodically(id: id, attempts: attempts + 1, maxAttempts: maxAttempts)
            }
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

