//
//  ContentView.swift
//  Kochi One
//
//  Created by APPLE on 01/10/2025.
//

import SwiftUI
import MapKit
import Combine





struct ContentView: View {
    let cameraPosition: MapCameraPosition = .region(.init(center: .init(latitude: 9.944465897354295, longitude: 76.2621801930728), latitudinalMeters: 10300, longitudinalMeters: 10300))
    @State private var showBottomBar: Bool = true
    @State private var currentDetent: AppTab.CustomDetent = .small
    @StateObject private var restaurantService = RestaurantService()
    @StateObject private var locationService = LocationService()
    @State private var showRestaurants: Bool = true
    @State private var transitCoordinates: [CLLocationCoordinate2D] = []
    // Smooth train movement state
    @State private var trainSegmentIndex: Int = 0
    @State private var trainProgress: Double = 0.0 // 0...1 within current segment
    @State private var lastTrainTick: Date? = nil
    private let trainSpeedMetersPerSecond: CLLocationDistance = 30 // adjust speed as needed
    private let trainTimer = Timer.publish(every: 1.0 / 30.0, on: .main, in: .common).autoconnect()
    private let headingOffsetDegrees: Double = 0 // adjust if asset points up or right
    var body: some View {
        Map(initialPosition: cameraPosition){
            // Dynamic restaurant annotations
            if showRestaurants {
                ForEach(restaurantService.restaurants) { restaurant in
                    Annotation("", coordinate: CLLocationCoordinate2D(
                        latitude: restaurant.location.latitude,
                        longitude: restaurant.location.longitude
                    ), anchor: .bottom) {
                        RestaurantAnnotationView(restaurant: restaurant)
                    }
                }
            }
                
            UserAnnotation()

            // Transit route polyline when in transit mode
            if !showRestaurants, !transitCoordinates.isEmpty {
                MapPolyline(coordinates: transitCoordinates)
                    .stroke(.blue, lineWidth: 4)

                // Moving metro icon along the route (interpolated)
                let segIdx = min(max(trainSegmentIndex, 0), max(transitCoordinates.count - 2, 0))
                let a = transitCoordinates[segIdx]
                let b = transitCoordinates[min(segIdx + 1, transitCoordinates.count - 1)]
                let trainCoord = interpolate(from: a, to: b, t: trainProgress)
                // Compute bearing to a small lookahead point for smoother direction
                let lookahead = forwardPoint(fromSegment: segIdx, progress: trainProgress, lookaheadMeters: 8)
                let bearing = calculateBearing(from: trainCoord, to: lookahead)
                Annotation("", coordinate: trainCoord, anchor: .center) {
                    Image("metro-icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .shadow(radius: 2)
                        .rotationEffect(.degrees(bearing + headingOffsetDegrees))
                }
            }
        }
        .onAppear {
            locationService.startLocationUpdates()
            restaurantService.fetchRestaurants()
            loadTransitRoute()
            lastTrainTick = Date()
        }
        .onReceive(trainTimer) { _ in
            guard !showRestaurants, transitCoordinates.count >= 2 else { return }
            let now = Date()
            let dt = lastTrainTick.map { now.timeIntervalSince($0) } ?? 0
            lastTrainTick = now
            guard dt > 0 else { return }

            var remainingMeters = trainSpeedMetersPerSecond * dt
            while remainingMeters > 0 {
                let a = transitCoordinates[trainSegmentIndex]
                let b = transitCoordinates[min(trainSegmentIndex + 1, transitCoordinates.count - 1)]
                let fullSegDist = distanceMeters(from: a, to: b)
                if fullSegDist <= 0.001 { // skip degenerate segments
                    if trainSegmentIndex + 1 >= transitCoordinates.count - 1 {
                        trainSegmentIndex = 0
                        trainProgress = 0
                        continue
                    } else {
                        trainSegmentIndex += 1
                        trainProgress = 0
                        continue
                    }
                }

                let remainingInSeg = (1.0 - trainProgress) * fullSegDist
                if remainingMeters >= remainingInSeg {
                    remainingMeters -= remainingInSeg
                    if trainSegmentIndex + 1 >= transitCoordinates.count - 1 {
                        trainSegmentIndex = 0
                        trainProgress = 0
                    } else {
                        trainSegmentIndex += 1
                        trainProgress = 0
                    }
                } else {
                    let deltaProgress = remainingMeters / fullSegDist
                    trainProgress = min(trainProgress + deltaProgress, 1.0)
                    remainingMeters = 0
                }
            }
        }
        .onChange(of: showRestaurants) { _, isShowingRestaurants in
            // When entering transit mode, start from beginning
            if !isShowingRestaurants {
                trainSegmentIndex = 0
                trainProgress = 0
                lastTrainTick = Date()
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapPitchToggle()
            MapScaleView()
        }
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll))
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

// MARK: - Transit Route Loader
extension ContentView {
    private func loadTransitRoute() {
        guard let url = Bundle.main.url(forResource: "map", withExtension: "geojson") else { return }
        do {
            let data = try Data(contentsOf: url)
            // Minimal parsing to extract LineString coordinates
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let features = json["features"] as? [[String: Any]],
               let first = features.first,
               let geometry = first["geometry"] as? [String: Any],
               let type = geometry["type"] as? String, type == "LineString",
               let coords = geometry["coordinates"] as? [[Double]] {
                let points = coords.compactMap { pair -> CLLocationCoordinate2D? in
                    guard pair.count == 2 else { return nil }
                    // GeoJSON is [lon, lat]
                    return CLLocationCoordinate2D(latitude: pair[1], longitude: pair[0])
                }
                self.transitCoordinates = points
            }
        } catch {
            // Silently ignore if parsing fails
        }
    }
    
    private func calculateBearing(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let lat1 = from.latitude * .pi / 180
        let lon1 = from.longitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let lon2 = to.longitude * .pi / 180
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        var degreesBearing = radiansBearing * 180 / .pi
        if degreesBearing < 0 { degreesBearing += 360 }
        return degreesBearing
    }

    private func interpolate(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, t: Double) -> CLLocationCoordinate2D {
        let clampedT = max(0.0, min(1.0, t))
        let lat = from.latitude + (to.latitude - from.latitude) * clampedT
        let lon = from.longitude + (to.longitude - from.longitude) * clampedT
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    private func distanceMeters(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let a = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let b = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return a.distance(from: b)
    }

    // Finds a point ahead along the polyline from the current segment/progress by a given distance.
    private func forwardPoint(fromSegment segIdx: Int, progress: Double, lookaheadMeters: CLLocationDistance) -> CLLocationCoordinate2D {
        guard transitCoordinates.count >= 2 else { return transitCoordinates.first ?? CLLocationCoordinate2D() }
        var index = max(0, min(segIdx, transitCoordinates.count - 2))
        var t = max(0.0, min(1.0, progress))
        var current = interpolate(from: transitCoordinates[index], to: transitCoordinates[index + 1], t: t)
        var remaining = lookaheadMeters

        while remaining > 0 {
            let a = current
            let b: CLLocationCoordinate2D = {
                if t < 1.0 {
                    return interpolate(from: transitCoordinates[index], to: transitCoordinates[index + 1], t: min(t + 0.01, 1.0))
                } else if index + 1 < transitCoordinates.count - 1 {
                    return transitCoordinates[index + 2]
                } else {
                    return transitCoordinates.last!
                }
            }()
            let segDist = distanceMeters(from: a, to: b)
            if segDist <= 0.001 { break }
            if segDist >= remaining {
                // Move proportionally towards b
                let dt = remaining / segDist
                if t < 1.0 {
                    t = min(t + dt, 1.0)
                    current = interpolate(from: transitCoordinates[index], to: transitCoordinates[index + 1], t: t)
                } else {
                    // Already at end of this segment, step into next point
                    current = interpolate(from: a, to: b, t: dt)
                }
                remaining = 0
            } else {
                remaining -= segDist
                if t < 1.0 {
                    t = 1.0
                    current = interpolate(from: transitCoordinates[index], to: transitCoordinates[index + 1], t: t)
                } else if index + 1 < transitCoordinates.count - 1 {
                    index += 1
                    t = 0
                    current = transitCoordinates[index]
                } else {
                    // End of the route
                    current = transitCoordinates.last!
                    break
                }
            }
        }
        return current
    }
}

extension CLLocationCoordinate2D {
    static let kochi = CLLocationCoordinate2D(latitude: 9.944465897354295, longitude: 76.2621801930728)
}

struct RestaurantAnnotationView: View {
    let restaurant: Restaurant
    
    // Computed property to determine border color based on restaurant type
    private var borderColor: Color {
        switch restaurant.restaurantType?.lowercased() {
        case "cafe":
            return .green
        case "restaurant":
            return .blue
        default:
            return .red
        }
    }
    
    // Computed property to determine background color for placeholder
    private var placeholderBackgroundColor: Color {
        switch restaurant.restaurantType?.lowercased() {
        case "cafe":
            return .green
        case "restaurant":
            return .blue
        default:
            return .red
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            AsyncImage(url: URL(string: restaurant.logo?.url ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(borderColor, lineWidth: 3)
                    )
            } placeholder: {
                Image(systemName: "fork.knife")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .padding(7)
                    .background(placeholderBackgroundColor.gradient, in: .circle)
            }
            
            Text(restaurant.name)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.ultraThinMaterial, in: .capsule)
                .lineLimit(1)
        }
    }
}

#Preview {
    ContentView()
}
