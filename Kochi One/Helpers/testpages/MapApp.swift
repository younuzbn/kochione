////
////  MapApp.swift
////  Kochi One
////
////  Created by Muhammed Younus on 25/11/25.
////
//
//
////
////  EatsView.swift
////  Kochi One
////
////  Created by APPLE on 01/10/2025.
////
//
//import SwiftUI
//import CoreLocation
//
//// Map App Types
//enum MapApp: String, Identifiable {
//    case appleMaps = "Apple Maps"
//    case googleMaps = "Google Maps"
//    case waze = "Waze"
//    
//    var id: String { rawValue }
//    
//    var urlScheme: String {
//        switch self {
//        case .appleMaps:
//            return "http://maps.apple.com/"
//        case .googleMaps:
//            return "comgooglemaps://"
//        case .waze:
//            return "waze://"
//        }
//    }
//    
//    var icon: String {
//        switch self {
//        case .appleMaps:
//            return "map.fill"
//        case .googleMaps:
//            return "map.fill"
//        case .waze:
//            return "map.fill"
//        }
//    }
//    
//    // Check if the map app is available on the device
//    static func availableApps() -> [MapApp] {
//        var available: [MapApp] = []
//        
//        // Apple Maps is always available on iOS
//        available.append(.appleMaps)
//        
//        // Check Google Maps
//        if let url = URL(string: "comgooglemaps://") {
//            if UIApplication.shared.canOpenURL(url) {
//                available.append(.googleMaps)
//            }
//        }
//        
//        // Check Waze
//        if let url = URL(string: "waze://") {
//            if UIApplication.shared.canOpenURL(url) {
//                available.append(.waze)
//            }
//        }
//        
//        return available
//    }
//   
//  
//    // Generate URL for navigation with coordinates and business name
//    func navigationURL(latitude: Double, longitude: Double, businessName: String? = nil) -> URL? {
//        switch self {
//        case .appleMaps:
//            // Apple Maps supports q parameter with label
//            if let name = businessName, !name.isEmpty {
//                let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
//                return URL(string: "http://maps.apple.com/?daddr=\(latitude),\(longitude)&q=\(encodedName)&dirflg=d")
//            } else {
//                return URL(string: "http://maps.apple.com/?daddr=\(latitude),\(longitude)&dirflg=d")
//            }
//        case .googleMaps:
//            // Google Maps: Use daddr for navigation (not q which just shows location)
//            // For business name, we can append it to coordinates with + separator
//            if let name = businessName, !name.isEmpty {
//                let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
//                // Format: daddr=latitude,longitude+label for navigation with label
//                return URL(string: "comgooglemaps://?daddr=\(latitude),\(longitude)+\(encodedName)&directionsmode=driving")
//            } else {
//                return URL(string: "comgooglemaps://?daddr=\(latitude),\(longitude)&directionsmode=driving")
//            }
//        case .waze:
//            // Waze doesn't support labels in URL scheme, but we can try adding it as a note
//            // Note: Waze URL scheme doesn't officially support business names
//            return URL(string: "waze://?ll=\(latitude),\(longitude)&navigate=yes")
//        }
//    }
//}
//
//// Main EatsView function that handles search integration
//func EatsView(activeSheet: Binding<BottomBarView.SheetType?>, locationService: LocationService, restaurantService: RestaurantService, selectedRestaurantName: Binding<String?>) -> some View {
//    EatsViewM(restaurantService: restaurantService, locationService: locationService, selectedRestaurantName: selectedRestaurantName)
//}
////---------------------------------------------------//
////MARK: operatingHours FINDER
////let restauran:Restaurant
////let operatingHours = restauran.operatingHours
////
////func getTodayHours() -> (isClosed: Bool, opening: String, closing: String) {
////    let formatter = DateFormatter()
////    formatter.dateFormat = "EEEE"
////    
////    let today = formatter.string(from: Date()).lowercased()
////    
////    let data = operatingHours[today]!
////    let closed = data["closed"] as? Bool ?? true
////    let opening = data["openingTime"] as? String ?? ""
////    let closing = data["closingTime"] as? String ?? ""
////    
////    return (closed, opening, closing)
////}
//
////MARK: 24HR TO 12 HR
////func convertTo12Hour(_ time24: String) -> String {
////    let formatter = DateFormatter()
////    formatter.dateFormat = "HH:mm"
////    formatter.locale = .init(identifier: "en_US_POSIX")
////
////    let outputFormatter = DateFormatter()
////    outputFormatter.dateFormat = "hh:mm a"
////    outputFormatter.locale = .init(identifier: "en_US_POSIX")
////
////    if let date = formatter.date(from: time24) {
////        return outputFormatter.string(from: date)
////    } else {
////        return "Invalid time"
////    }
////}
//
//
////MARK: STOREOPEN FINDER
//
////func isStoreOpen(opening: String, closing: String) -> Bool {
////    let formatter = DateFormatter()
////    formatter.dateFormat = "HH:mm"
////    formatter.locale = .init(identifier: "en_US_POSIX")
////    
////    guard let openDate = formatter.date(from: opening),
////          let closeDate = formatter.date(from: closing) else {
////        return false
////    }
////    
////    let now = Date()
////    let calendar = Calendar.current
////    
////    let todayOpen = calendar.date(
////        bySettingHour: calendar.component(.hour, from: openDate),
////        minute: calendar.component(.minute, from: openDate),
////        second: 0,
////        of: now
////    )!
////    
////    let todayClose = calendar.date(
////        bySettingHour: calendar.component(.hour, from: closeDate),
////        minute: calendar.component(.minute, from: closeDate),
////        second: 0,
////        of: now
////    )!
////    
////    return now >= todayOpen && now <= todayClose
////}
//// MARK: Get Today’s Data
////func getTodayHours() -> (isClosed: Bool, opening: String, closing: String) {
////    let formatter = DateFormatter()
////    formatter.dateFormat = "EEEE"
////    
////    let today = formatter.string(from: Date()).lowercased()
////    
////    let data = operatingHours[today]!
////    let closed = data["closed"] as? Bool ?? true
////    let opening = data["openingTime"] as? String ?? ""
////    let closing = data["closingTime"] as? String ?? ""
////    
////    return (closed, opening, closing)
////}
//
//
//
//
//// --- The original post template view ---
//struct EatsViewFull: View {
//    @State private var activeID: String?
//    @Binding var showDetail: Bool
//    let restaurant: Restaurant
//    @ObservedObject var locationService: LocationService
//    @State private var showMapPicker = false
//   
//    var body: some View {
//        /// Remove the NavigationStack here, as IndividualTabView is already in a ScrollView
//        VStack {
//            HStack(alignment: .top, spacing: 12) {
//                CachedAsyncImage(url: restaurant.logo?.url ?? "") { image in
//                    image
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: 45, height: 45)
//                        .clipShape(Circle())
//                } placeholder: {
//                    Circle()
//                        .fill(.fill)
//                        .frame(width: 45, height: 45)
//                }
//                
//                VStack(alignment: .leading, spacing: 4) {
//                    HStack {
//                        if !restaurant.name.isEmpty {
//                            // 1. DATA LOADED: Show the actual restaurant name
//                            Text(restaurant.name)
//                                .font(.headline)
//                                .lineLimit(1)
//                        } else {
//                            // 2. PLACEHOLDER: Show the rectangle when the name is not available
//                            Rectangle()
//                                .fill(.fill)
//                                .frame(width: 150, height: 18) // Adjusted size
//                                .clipShape(.rect(cornerRadius: 3))
//                        }
//                        Spacer()
//                            .foregroundColor(.secondary)
//                        Text(locationService.calculateDistance(to: restaurant))
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                        Image(systemName: "location.north.line.fill")
//                            .foregroundColor(.blue)
//                            .rotationEffect(.degrees(locationService.calculateBearing(to: restaurant)))
//                    }
//                    
//                    Group {
//                        if !restaurant.description.isEmpty {
//                            // 1. DATA LOADED: Show the actual description text
//                            Text(restaurant.description)
//                                .font(.subheadline)
//                                .lineLimit(4) // Limit to match the visual space of the 4 lines of placeholders
//                        } else {
//                            // 2. PLACEHOLDER: Show the repeated rectangles when description is not available
//                            VStack(alignment: .leading, spacing: 5) { // Added alignment .leading for text-like justification
//                                ForEach(1...4, id: \.self) { index in
//                                    Rectangle()
//                                        .fill(.fill)
//                                        .frame(height: 5)
//                                        // Make the last line shorter to simulate real text
//                                        .padding(.trailing, index == 4 ? 50 : 0)
//                                }
//                            }
//                        }
//                    } // The Group is optional here, but makes the intent clear
//                    .padding(.top, 10)    // <--- MODIFIERS MOVED AND APPLIED HERE
//                    .padding(.bottom, 20)
//                    
//
//                    
//                    let config = ImageViewerConfig(height: 100, cornerRadius: 10, spacing: 5)
//                    
//                    ImageViewer(config: config) {
//                        ForEach(restaurant.coverImages.prefix(4), id: \.url) { coverImage in
//                            CachedAsyncImage(url: coverImage.url) { image in
//                                image
//                                    .resizable()
//                            } placeholder: {
//                                Rectangle()
//                                    .fill(.gray.opacity(0.4))
//                                    .overlay {
//                                        ProgressView()
//                                            .tint(.blue)
//                                            .scaleEffect(0.7)
//                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
//                                    }
//                            }
//                            .containerValue(\.activeViewID, coverImage.url)
//                        }
//                    } overlay: {
//                        OverlayViewEats(activeID: activeID, restaurant: restaurant)
//                    } updates: { isPresented, activeID in
//                        self.activeID = activeID?.base as? String
//                    }
//                    
//                    HStack {
//                                            // 1. Call Button
//                                            Button {
//                                                print("Call button tapped")
//                                                // Action: Make a phone call to the restaurant
//                                                let phoneNumber = restaurant.contact.phone
//                                                guard !phoneNumber.isEmpty else {
//                                                    print("Phone number is empty")
//                                                    return
//                                                }
//                                                
//                                                // Clean phone number: remove spaces, dashes, parentheses, etc., but keep + for international
//                                                let cleanedNumber = phoneNumber
//                                                    .replacingOccurrences(of: " ", with: "")
//                                                    .replacingOccurrences(of: "-", with: "")
//                                                    .replacingOccurrences(of: "(", with: "")
//                                                    .replacingOccurrences(of: ")", with: "")
//                                                    .replacingOccurrences(of: ".", with: "")
//                                                
//                                                if let phoneURL = URL(string: "tel://\(cleanedNumber)") {
//                                                    if UIApplication.shared.canOpenURL(phoneURL) {
//                                                        UIApplication.shared.open(phoneURL)
//                                                    } else {
//                                                        print("Cannot open phone URL: \(phoneURL)")
//                                                    }
//                                                } else {
//                                                    print("Invalid phone number format: \(cleanedNumber)")
//                                                }
//                                            } label: {
//                                                Image(systemName: "phone")
//                                                
//                                            }
//                                            
//                                            Spacer()
//                                            
//                                            // 2. Navigation Button
//                                            Button {
//                                                print("Navigation button tapped")
//                                                // Show map picker if multiple apps available, otherwise open directly
//                                                let availableApps = MapApp.availableApps()
//                                                if availableApps.count == 1, let app = availableApps.first {
//                                                    // Only one app available, open directly
//                                                    if let url = app.navigationURL(latitude: restaurant.location.latitude, longitude: restaurant.location.longitude, businessName: restaurant.name) {
//                                                        UIApplication.shared.open(url)
//                                                    }
//                                                } else {
//                                                    // Multiple apps available, show picker
//                                                    showMapPicker = true
//                                                }
//                                            } label: {
//                                                Image(systemName: "location")
//                                            }
//                                            .confirmationDialog("Choose Navigation App", isPresented: $showMapPicker, titleVisibility: .visible) {
//                                                ForEach(MapApp.availableApps()) { app in
//                                                    Button(app.rawValue) {
//                                                        if let url = app.navigationURL(latitude: restaurant.location.latitude, longitude: restaurant.location.longitude, businessName: restaurant.name) {
//                                                            UIApplication.shared.open(url)
//                                                        }
//                                                    }
//                                                }
//                                                Button("Cancel", role: .cancel) { }
//                                            }
//
//                                            Spacer()
//                                            
//                                            // 3. Like/Heart Button
//                                            Button {
//                                                print("Like button tapped")
//                                                // Action: Toggle the liked state for this post
//                                            } label: {
//                                                Image(systemName: "suit.heart")
//                                            }
//
//                                            Spacer()
//                                            
//                                            // 4. Share Button
//                                            Button {
//                                                print("Share button tapped")
//                                                // Action: Show a native share sheet
//                                            } label: {
//                                                Image(systemName: "square.and.arrow.up")
//                                            }
//                                        }
//                                        .foregroundStyle(.primary.secondary)
//                                        .padding(.top, 10)
//                }
//                .padding(.top, 10)
//            }
//            .padding([.leading, .trailing], 15) // Only apply horizontal padding to content
//
//            Spacer(minLength: 0)
//        }
//        .contentShape(Rectangle()) // Makes the whole post area tappable
//    }
//}
//
//// --- NEW Wrapper View to display multiple posts ---
//struct EatsViewM: View {
//    @ObservedObject var restaurantService: RestaurantService
//    @ObservedObject var locationService: LocationService
//    @State private var showDetail = false
//    @State private var selectedRestaurant: Restaurant?
//    @Binding var selectedRestaurantName: String?
//    @State private var selectedCategory: String = "All"
//    @StateObject private var eatsMapState = EatsMapState.shared
//    
//    // Hardcoded categories - always available even if API fails
//    let availableCategories: [String] = [
//        "All",
//        "Restaurants",
//        "Cafes",
//        "Pubs & Bars",
//        "Juice & Shake",
//        "Food Truck",
//        "Bakeries & Desserts",
//        "Buffet & Fine Dining"
//    ]
//    
//    // Filter restaurants based on selected category using API restaurantType
//    // Use @State to hold filtered results - updated via onChange to prevent recomputation on every view update
//    @State private var filteredRestaurants: [Restaurant] = []
//    
//    private func computeFilteredRestaurants() -> [Restaurant] {
//        // Filter active restaurants first (most efficient)
//        let activeRestaurants = restaurantService.restaurants.filter { $0.isActive }
//        
//        // If "All" selected, return all active restaurants
//        guard selectedCategory != "All" else {
//            return activeRestaurants
//        }
//        
//        let categoryLower = selectedCategory.lowercased()
//        
//        // Pre-compile keywords for better performance
//        let keywords: [String]
//        switch categoryLower {
//        case "restaurants":
//            keywords = ["restaurant", "fine dining", "multicuisine", "family restaurant"]
//        case "cafes":
//            keywords = ["cafe", "coffee", "cowork", "chill spot"]
//        case "pubs & bars":
//            keywords = ["pub", "bar", "nightlife", "live music", "cocktail", "lounge"]
//        case "juice & shake":
//            keywords = ["juice", "shake", "smoothie", "mocktail", "fresh juice"]
//        case "food truck":
//            keywords = ["food truck", "truck", "mobile food", "street vendor", "night eats", "local street"]
//        case "bakeries & desserts":
//            keywords = ["bakery", "dessert", "cake", "pastry", "ice cream", "sweet"]
//        case "buffet & fine dining":
//            keywords = ["buffet", "fine dining", "luxury", "hotel"]
//        default:
//            // Fallback: exact match
//            return activeRestaurants.filter { restaurant in
//                restaurant.restaurantType?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == categoryLower
//            }
//        }
//        
//        // Filter with pre-compiled keywords
//        return activeRestaurants.filter { restaurant in
//            guard let restaurantType = restaurant.restaurantType?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) else {
//                return false
//            }
//            
//            // Special handling for cafes to avoid matching "cafeteria"
//            if categoryLower == "cafes" {
//                return matchesCategory(restaurantType, keywords: keywords) && !restaurantType.contains("cafeteria")
//            }
//            
//            return matchesCategory(restaurantType, keywords: keywords)
//        }
//    }
//    
//    // Helper function to update filtered restaurants
//    private func updateFilteredRestaurants() {
//        filteredRestaurants = computeFilteredRestaurants()
//    }
//    
//    // Helper function to check if restaurantType matches any keywords
//    private func matchesCategory(_ restaurantType: String, keywords: [String]) -> Bool {
//        return keywords.contains { keyword in
//            restaurantType.contains(keyword)
//        }
//    }
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            // Category Switcher (similar to TransitView) - always show
//            CustomCategoryControl(
//                selection: $selectedCategory,
//                options: availableCategories
//            )
//            .padding(.horizontal, 8)
//            .padding(.vertical, 6)
//            .padding(.bottom, 12) // Add more space below category tab
//            
//            // Show list view
//            ScrollView(.vertical, showsIndicators: false) {
//                LazyVStack(spacing: 0) { // spacing: 0 to remove extra padding between the EatsViewFull content
//                    if restaurantService.isLoading {
//                        VStack {
//                            ProgressView("Loading restaurants...")
//                                .padding()
//                        }
//                    } else if filteredRestaurants.isEmpty {
//                        VStack {
//                            Text("No restaurants available")
//                                .foregroundColor(.secondary)
//                                .padding()
//                        }
//                    } else {
//                        ForEach(filteredRestaurants) { restaurant in
//                            EatsViewFull(showDetail: $showDetail, restaurant: restaurant, locationService: locationService)
//                                .onTapGesture {
//                                    print("Restaurant tapped: \(restaurant.name)")
//                                    selectedRestaurant = restaurant
//                                    selectedRestaurantName = restaurant.name
//                                    showDetail = true
//                                }
//                            
//                            // Add a subtle separator between posts
//                            Divider()
//                                .padding(.vertical, 10)
//                                .padding(.horizontal, 15)
//                        }
//                    }
//                }
//            }
//        }
//        .fullScreenCover(isPresented: $showDetail) {
//            if let restaurant = selectedRestaurant {
//                EatsDetailView(restaurant: restaurant, locationService: locationService) {
//                    // Back button action
//                    showDetail = false
//                    selectedRestaurant = nil
//                    selectedRestaurantName = nil
//                }
//            }
//        }
//        .onAppear {
//            // Only fetch if we don't have data yet
//            if restaurantService.restaurants.isEmpty && !restaurantService.isLoading {
//                restaurantService.fetchRestaurants()
//            }
//            // Initialize filtered restaurants
//            updateFilteredRestaurants()
//            // Sync initial category with map state
//            eatsMapState.selectedCategory = selectedCategory
//        }
//        .onChange(of: selectedCategory) { oldValue, newValue in
//            // Recompute when category changes
//            updateFilteredRestaurants()
//            // Update map state for annotation filtering
//            eatsMapState.selectedCategory = newValue
//        }
//        .onChange(of: restaurantService.restaurants.count) { oldValue, newValue in
//            // Recompute when restaurants change
//            if newValue != oldValue {
//                updateFilteredRestaurants()
//            }
//        }
//        .onChange(of: restaurantService.isLoading) { oldValue, newValue in
//            // Recompute when loading completes
//            if !newValue && oldValue {
//                updateFilteredRestaurants()
//            }
//        }
//        .alert("Error", isPresented: .constant(restaurantService.errorMessage != nil)) {
//            Button("OK") {
//                restaurantService.errorMessage = nil
//            }
//        } message: {
//            Text(restaurantService.errorMessage ?? "")
//        }
//        .alert("Location Permission Required", isPresented: .constant(locationService.authorizationStatus == .denied)) {
//            Button("Settings") {
//                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
//                    UIApplication.shared.open(settingsUrl)
//                }
//            }
//            Button("Cancel", role: .cancel) { }
//        } message: {
//            Text("Please enable location access in Settings to see distances to restaurants.")
//        }
//    }
//}
//
//
//struct EatsDetailView: View {
//    let restaurant: Restaurant
//    @ObservedObject var locationService: LocationService
//    let onBack: () -> Void
//    var body: some View {
//            VStack{
//                    ChangedDetailsPage(restaurant: restaurant, locationService: locationService, onBack: onBack)
//            }
//        .ignoresSafeArea()
//        .navigationBarHidden(true)
//    }
//}
//
//
///// Overlay View
//struct OverlayViewEats: View {
//    var activeID: String?
//    let restaurant: Restaurant
//    @Environment(\.dismiss) private var dismiss
//    var body: some View {
//        VStack {
//            Button {
//                dismiss()
//            } label: {
//                Image(systemName: "chevron.left")
//                    .font(.title3)
//                    .foregroundStyle(.white.secondary)
//                    .padding(10)
//                    .contentShape(.rect)
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .overlay {
//                if let coverImage = restaurant.coverImages.first(where: { $0.url == activeID }) {
//                    Text(coverImage.alt ?? restaurant.name)
//                        .font(.callout)
//                        .foregroundStyle(.white)
//                }
//            }
//            
//            Spacer(minLength: 0)
//        }
//        .padding(15)
//    }
//}
//
//// MARK: - Custom Category Control (similar to TransitView's CustomSegmentedControl)
//struct CustomCategoryControl: View {
//    @Binding var selection: String
//    let options: [String]
//    @Namespace private var animation
//    @Environment(\.colorScheme) var colorScheme
//    
//    // Get icon for each category
//    private func icon(for option: String) -> String {
//        let lowercased = option.lowercased()
//        switch lowercased {
//        case "all":
//            return "square.grid.2x2.fill"
//        case "restaurants":
//            return "fork.knife"
//        case "cafes":
//            return "cup.and.saucer.fill"
//        case "pubs & bars":
//            return "wineglass.fill"
//        case "juice & shake":
//            return "takeoutbag.and.cup.and.straw.fill"
//        case "food truck":
//            return "car.fill"
//        case "bakeries & desserts":
//            return "birthday.cake.fill"
//        case "buffet & fine dining":
//            return "sparkles"
//        default:
//            return "circle.fill"
//        }
//    }
//    
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 8) {
//                ForEach(options, id: \.self) { option in
//                    Button {
//                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//                            selection = option
//                        }
//                    } label: {
//                        ZStack {
//                            // Selected background with pill shape - black in light mode, white in dark mode
//                            if selection == option {
//                                RoundedRectangle(cornerRadius: 20)
//                                    .fill(colorScheme == .dark ? Color.white : Color.black)
//                                    .shadow(color: colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
//                                    .matchedGeometryEffect(id: "selectedCategory", in: animation)
//                            }
//                            
//                            // Content: Icon + Text for selected, Icon only for unselected
//                            HStack(spacing: 6) {
//                                Image(systemName: icon(for: option))
//                                    .font(.system(size: 16, weight: selection == option ? .semibold : .medium))
//                                    .foregroundStyle(selection == option ? (colorScheme == .dark ? .black : .white) : .primary)
//                                
//                                if selection == option {
//                                    Text(option)
//                                        .font(.system(size: 15, weight: .semibold))
//                                        .foregroundStyle(colorScheme == .dark ? .black : .white)
//                                }
//                            }
//                            .padding(.horizontal, selection == option ? 18 : 12)
//                            .padding(.vertical, 10)
//                        }
//                        .contentShape(Rectangle())
//                    }
//                    .buttonStyle(.plain)
//                }
//            }
//            .padding(.horizontal, 6)
//            .padding(.vertical, 4)
//        }
//        .background(
//            RoundedRectangle(cornerRadius: 24)
//                .fill(Color(.systemGray6))
//                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
//        )
//    }
//}
