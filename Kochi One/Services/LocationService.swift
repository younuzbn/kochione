import Foundation
import CoreLocation
internal import Combine

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationAvailable: Bool = false
    @Published var heading: CLLocationDirection = 0.0
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.headingFilter = 1.0 // Update heading every 1 degree
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return
        }
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        isLocationAvailable = true
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            startLocationUpdates()
        } else {
            isLocationAvailable = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        isLocationAvailable = false
    }
    
    // MARK: - Distance Calculation
    
    func calculateDistance(to restaurant: Restaurant) -> String {
        guard let userLocation = currentLocation else {
            return "Location unavailable"
        }
        
        let restaurantLocation = CLLocation(
            latitude: restaurant.location.latitude,
            longitude: restaurant.location.longitude
        )
        
        let distanceInMeters = userLocation.distance(from: restaurantLocation)
        let distanceInKm = distanceInMeters / 1000
        
        if distanceInKm < 1 {
            return String(format: "%.0f m", distanceInMeters)
        } else {
            return String(format: "%.1f km", distanceInKm)
        }
    }
    
    // MARK: - Bearing Calculation
    
    func calculateBearing(to restaurant: Restaurant) -> Double {
        guard let userLocation = currentLocation else {
            return 0.0
        }
        
        let userLat = userLocation.coordinate.latitude * .pi / 180
        let userLon = userLocation.coordinate.longitude * .pi / 180
        let restaurantLat = restaurant.location.latitude * .pi / 180
        let restaurantLon = restaurant.location.longitude * .pi / 180
        
        let deltaLon = restaurantLon - userLon
        
        let y = sin(deltaLon) * cos(restaurantLat)
        let x = cos(userLat) * sin(restaurantLat) - sin(userLat) * cos(restaurantLat) * cos(deltaLon)
        
        let bearing = atan2(y, x)
        let bearingDegrees = bearing * 180 / .pi
        
        // Convert to 0-360 range
        let absoluteBearing = (bearingDegrees + 360).truncatingRemainder(dividingBy: 360)
        
        // Calculate relative bearing from phone's current orientation
        let relativeBearing = absoluteBearing - heading
        
        // Normalize to -180 to 180 range
        let normalizedBearing = ((relativeBearing + 180).truncatingRemainder(dividingBy: 360)) - 180
        
        return normalizedBearing
    }
}
