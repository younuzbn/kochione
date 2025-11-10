//
//  ContentView.swift
//  Kochi One
//
//  Created by APPLE on 01/10/2025.
//

import SwiftUI
import MapKit
internal import Combine





struct ContentView: View {
    let cameraPosition: MapCameraPosition = .region(.init(center: .init(latitude: 9.994485997354295, longitude: 76.3021801930728), latitudinalMeters: 15300, longitudinalMeters: 15300))
    @State private var showBottomBar: Bool = true
    @State private var currentDetent: AppTab.CustomDetent = .small
    @StateObject private var restaurantService = RestaurantService()
    @StateObject private var locationService = LocationService()
    @StateObject private var metroMapState = MetroMapState.shared
    @StateObject private var metroService = MetroDataService.shared
    @StateObject private var eatsMapState = EatsMapState.shared
    @State private var showRestaurants: Bool = true
    private let routeUpdateTimer = Timer.publish(every: 5.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Map(initialPosition: cameraPosition) {
            // Dynamic restaurant annotations - filtered by selected category
            if showRestaurants {
                ForEach(filteredRestaurantsForMap) { restaurant in
                    Annotation("", coordinate: CLLocationCoordinate2D(
                        latitude: restaurant.location.latitude,
                        longitude: restaurant.location.longitude
                    ), anchor: .bottom) {
                        RestaurantAnnotationView(restaurant: restaurant)
                    }
                }
            }
                
            UserAnnotation()

            // Metro Station Annotations when in transit tab and metro is selected
            if metroMapState.isMetroTabActive && metroMapState.showMetroStations {
                ForEach(metroService.stations) { station in
                    let isFromStation = metroMapState.fromStation?.id == station.id
                    let isToStation = metroMapState.toStation?.id == station.id
                    let isInRoute = metroMapState.stationsInRoute.contains(where: { $0.id == station.id })
                    
                    Annotation("", coordinate: station.coordinate, anchor: .center) {
                        MetroStationAnnotationView(
                            station: station,
                            isFromStation: isFromStation,
                            isToStation: isToStation,
                            isInRoute: isInRoute
                        )
                    }
                }
            }
            
            // Selected Route Polyline (when a metro timing is clicked)
            if !metroMapState.routeCoordinates.isEmpty {
                MapPolyline(coordinates: metroMapState.routeCoordinates)
                    .stroke(.blue, lineWidth: 4)
            }
            
            // Train Position Marker (when route is selected)
            if let trainPosition = metroMapState.trainPosition {
                Annotation("", coordinate: trainPosition, anchor: .center) {
                    Image("metro-icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 3)
                        .overlay(
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 48, height: 48)
                        )
                }
            }
        }
        .onAppear {
            locationService.startLocationUpdates()
            restaurantService.fetchRestaurants()
        }
        .onReceive(routeUpdateTimer) { _ in
            // Update train position for selected route
            updateSelectedRouteTrainPosition()
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapPitchToggle()
            MapScaleView()
        }
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll))
        .safeAreaInset(edge: .bottom) {
            // Add bottom padding to prevent map labels from being hidden by bottom sheet
            Spacer()
                .frame(height: bottomSheetHeight)
        }
        .sheet(isPresented: $showBottomBar) {
                BottomBarView(currentDetent: $currentDetent, showRestaurants: $showRestaurants, locationService: locationService)
                    .presentationBackgroundInteraction(.enabled)
                    .presentationDetents(
                                            [
                                                .height(isiOS26 ? 80 : 130), // .small
                                                .fraction(0.6),             // .medium
                                                .large                      // .large
                                            ],
                                            selection: detentBinding()
                                        )
                    
            }
    }
    
    // Calculate bottom sheet height - always use small detent height to keep map position consistent
    private var bottomSheetHeight: CGFloat {
        // Always use the small detent height so map position stays consistent
        // regardless of bottom sheet size
        return isiOS26 ? 80 : 130
    }
    
    // Helper to create the appropriate Binding<PresentationDetent>
        private func detentBinding() -> Binding<PresentationDetent> {
            Binding<PresentationDetent> {
                switch currentDetent {
                case .small:
                    return .height(isiOS26 ? 80 : 130)
                case .medium:
                    return .fraction(0.6)
                case .large:
                    return .large
                }
            } set: { newDetent in
                // This closure can also handle changes if the user drags the sheet
                if newDetent == .large {
                    currentDetent = .large
                } else if newDetent == .fraction(0.6) {
                    currentDetent = .medium
                } else {
                    currentDetent = .small
                }
            }
        }

}

extension CLLocationCoordinate2D {
    static let kochi = CLLocationCoordinate2D(latitude: 9.944465897354295, longitude: 76.2621801930728)
}

// MARK: - Restaurant Filtering Extension
extension ContentView {
    // Filter restaurants for map annotations based on selected category
    var filteredRestaurantsForMap: [Restaurant] {
        let activeRestaurants = restaurantService.restaurants.filter { $0.isActive }
        
        // If "All" selected, show all active restaurants
        guard eatsMapState.selectedCategory != "All" else {
            return activeRestaurants
        }
        
        let categoryLower = eatsMapState.selectedCategory.lowercased()
        
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
    
    // Helper function to check if restaurantType matches any keywords
    private func matchesCategory(_ restaurantType: String, keywords: [String]) -> Bool {
        return keywords.contains { keyword in
            restaurantType.contains(keyword)
        }
    }
}

// MARK: - Route Update Extension
extension ContentView {
    private func updateSelectedRouteTrainPosition() {
        guard let trip = metroMapState.selectedTrip,
              let fromStation = metroMapState.fromStation,
              let toStation = metroMapState.toStation,
              !metroMapState.stationsInRoute.isEmpty else {
            return
        }
        
        // Get stop times
        guard let fromStopTime = trip.stopTimes.first(where: { $0.stopId == fromStation.id }),
              let toStopTime = trip.stopTimes.first(where: { $0.stopId == toStation.id }) else {
            return
        }
        
        // Calculate current train position
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentSecond = calendar.component(.second, from: now)
        let currentTimeInSeconds = currentHour * 3600 + currentMinute * 60 + currentSecond
        
        // Parse departure time
        let fromTimeComponents = fromStopTime.departureTime.components(separatedBy: ":")
        guard fromTimeComponents.count == 3,
              let fromHour = Int(fromTimeComponents[0]),
              let fromMinute = Int(fromTimeComponents[1]),
              let fromSecond = Int(fromTimeComponents[2]) else {
            return
        }
        
        let fromTimeInSeconds = fromHour * 3600 + fromMinute * 60 + fromSecond
        
        // Parse arrival time
        let toTimeComponents = toStopTime.arrivalTime.components(separatedBy: ":")
        guard toTimeComponents.count == 3,
              let toHour = Int(toTimeComponents[0]),
              let toMinute = Int(toTimeComponents[1]),
              let toSecond = Int(toTimeComponents[2]) else {
            return
        }
        
        let toTimeInSeconds = toHour * 3600 + toMinute * 60 + toSecond
        
        // Check if train has started
        if currentTimeInSeconds < fromTimeInSeconds {
            // Train hasn't started yet, return from station
            metroMapState.trainPosition = fromStation.coordinate
            return
        }
        
        // Check if train has arrived
        if currentTimeInSeconds >= toTimeInSeconds {
            // Train has arrived, return to station
            metroMapState.trainPosition = toStation.coordinate
            return
        }
        
        // Calculate progress (0.0 to 1.0)
        let totalDuration = toTimeInSeconds - fromTimeInSeconds
        let elapsed = currentTimeInSeconds - fromTimeInSeconds
        let progress = Double(elapsed) / Double(totalDuration)
        
        // Interpolate position between stations
        if metroMapState.stationsInRoute.count >= 2 {
            let segmentProgress = progress * Double(metroMapState.stationsInRoute.count - 1)
            let segmentIndex = Int(segmentProgress)
            let segmentT = segmentProgress - Double(segmentIndex)
            
            if segmentIndex < metroMapState.stationsInRoute.count - 1 {
                let fromCoord = metroMapState.stationsInRoute[segmentIndex].coordinate
                let toCoord = metroMapState.stationsInRoute[min(segmentIndex + 1, metroMapState.stationsInRoute.count - 1)].coordinate
                
                // Linear interpolation
                let lat = fromCoord.latitude + (toCoord.latitude - fromCoord.latitude) * segmentT
                let lon = fromCoord.longitude + (toCoord.longitude - fromCoord.longitude) * segmentT
                metroMapState.trainPosition = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
        }
    }
}

struct RestaurantAnnotationView: View {
    let restaurant: Restaurant
    
    // All annotations use blue color
    private var borderColor: Color {
        return .blue
    }
    
    // All placeholders use blue color
    private var placeholderBackgroundColor: Color {
        return .blue
    }
    
    var body: some View {
        VStack(spacing: 3) {
            AsyncImage(url: URL(string: restaurant.logo?.url ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(borderColor, lineWidth: 2)
                    )
            } placeholder: {
                Image(systemName: "fork.knife")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.white)
                    .frame(width: 14, height: 14)
                    .padding(5)
                    .background(placeholderBackgroundColor.gradient, in: .circle)
            }
            
            Text(restaurant.name)
                .font(.system(size: 9))
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(.ultraThinMaterial, in: .capsule)
                .lineLimit(1)
        }
    }
}

// MARK: - Metro Station Annotation View
struct MetroStationAnnotationView: View {
    let station: MetroStation
    let isFromStation: Bool
    let isToStation: Bool
    let isInRoute: Bool
    
    private var markerColor: Color {
        if isFromStation {
            return .blue // Starting point - blue
        } else if isToStation {
            return .red // Destination - red
        } else if isInRoute {
            return .green // Station in selected route - green
        } else {
            return .gray // Regular station - gray
        }
    }
    
    private var markerSize: CGFloat {
        if isFromStation || isToStation {
            return 24 // Larger for selected stations
        } else {
            return 18 // Regular size - smaller
        }
    }
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                // Outer ring for selected stations
                if isFromStation || isToStation {
                    Circle()
                        .fill(markerColor.opacity(0.2))
                        .frame(width: markerSize + 6, height: markerSize + 6)
                }
                
                // Main marker circle
                Circle()
                    .fill(markerColor)
                    .frame(width: markerSize, height: markerSize)
                    .overlay(
                        Circle()
                            .stroke(.white, lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                
                // Icon inside
                Image(systemName: isFromStation ? "mappin.circle.fill" : isToStation ? "mappin.circle.fill" : "tram.fill")
                    .font(.system(size: isFromStation || isToStation ? 12 : 10, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            // Station name label - only show for selected stations to reduce clutter
            if isFromStation || isToStation {
                Text(station.name)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.ultraThinMaterial, in: .capsule)
                    .lineLimit(1)
                    .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 0.5)
            }
        }
    }
}

#Preview {
    ContentView()
}
