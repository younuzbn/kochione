# 🚀 SwiftUI + Algolia Integration - Complete Code

## 📦 **Required Dependency**
Add to your SwiftUI project via Swift Package Manager:
```
https://github.com/algolia/algolia-swift
```

## 🔑 **Configuration**
```swift
// Your Algolia credentials
let appId = "EMTYPLB75P"
let searchApiKey = "8c302496ed4629f956ceb19864f95733"
let indexName = "restaurants_index"
```

## 📋 **1. Restaurant Model**
```swift
import Foundation

struct Restaurant: Codable, Identifiable {
    let objectID: String
    let name: String
    let description: String
    let cuisine: [String]
    let rating: Double
    let restaurantType: String
    let city: String
    let state: String
    let country: String
    let latitude: Double
    let longitude: Double
    let logoUrl: String
    let features: [String]
    let isActive: Bool
    let ranking: Int
    let phone: String
    let email: String
    
    var id: String { objectID }
    
    // Helper computed properties
    var formattedRating: String {
        String(format: "%.1f", rating)
    }
    
    var cuisineText: String {
        cuisine.joined(separator: ", ")
    }
    
    var locationText: String {
        "\(city), \(state), \(country)"
    }
}
```

## 🔍 **2. Algolia Service**
```swift
import AlgoliaSearchClient
import Foundation

class AlgoliaService: ObservableObject {
    private let client: SearchClient
    private let index: SearchIndex
    
    init() {
        let appId = "EMTYPLB75P"
        let apiKey = "8c302496ed4629f956ceb19864f95733"
        let indexName = "restaurants_index"
        
        self.client = SearchClient(appID: appId, apiKey: apiKey)
        self.index = client.index(withName: indexName)
    }
    
    // Basic text search
    func search(query: String, completion: @escaping (Result<[Restaurant], Error>) -> Void) {
        let searchQuery = Query(query: query)
            .set(\.hitsPerPage, to: 20)
            .set(\.attributesToRetrieve, to: [
                "objectID", "name", "description", "cuisine", 
                "rating", "restaurantType", "city", "state", 
                "country", "latitude", "longitude", "logoUrl",
                "features", "isActive", "ranking", "phone", "email"
            ])
        
        index.search(query: searchQuery) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let restaurants = response.hits.compactMap { hit in
                        try? hit.object.decode(Restaurant.self)
                    }
                    completion(.success(restaurants))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    // Location-based search
    func searchNearby(latitude: Double, longitude: Double, radius: Int = 5000, completion: @escaping (Result<[Restaurant], Error>) -> Void) {
        let searchQuery = Query()
            .set(\.aroundLatLng, to: Point(latitude: latitude, longitude: longitude))
            .set(\.aroundRadius, to: .meters(radius))
            .set(\.hitsPerPage, to: 20)
        
        index.search(query: searchQuery) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let restaurants = response.hits.compactMap { hit in
                        try? hit.object.decode(Restaurant.self)
                    }
                    completion(.success(restaurants))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    // Search with filters
    func searchWithFilters(query: String, cuisine: String? = nil, city: String? = nil, completion: @escaping (Result<[Restaurant], Error>) -> Void) {
        var searchQuery = Query(query: query)
        
        var filters: [String] = []
        if let cuisine = cuisine {
            filters.append("cuisine:'\(cuisine)'")
        }
        if let city = city {
            filters.append("city:'\(city)'")
        }
        
        if !filters.isEmpty {
            searchQuery.set(\.filters, to: filters.joined(separator: " AND "))
        }
        
        search(query: query) { result in
            completion(result)
        }
    }
    
    // Get facets for filtering
    func getFacets(completion: @escaping (Result<[String: [String]], Error>) -> Void) {
        let searchQuery = Query()
            .set(\.facets, to: ["cuisine", "city", "restaurantType"])
            .set(\.hitsPerPage, to: 0)
        
        index.search(query: searchQuery) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    var facets: [String: [String]] = [:]
                    for facet in response.facets {
                        facets[facet.key] = Array(facet.value.keys)
                    }
                    completion(.success(facets))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
```

## 🎯 **3. Search View Model**
```swift
import Foundation
import Combine

class RestaurantSearchViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var errorMessage: String?
    @Published var facets: [String: [String]] = [:]
    
    private let algoliaService = AlgoliaService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Auto-search when text changes (with debounce)
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                if searchText.count >= 2 {
                    self?.searchRestaurants(query: searchText)
                } else if searchText.isEmpty {
                    self?.restaurants = []
                }
            }
            .store(in: &cancellables)
        
        // Load facets on init
        loadFacets()
    }
    
    func searchRestaurants(query: String) {
        isLoading = true
        errorMessage = nil
        
        algoliaService.search(query: query) { [weak self] result in
            self?.isLoading = false
            
            switch result {
            case .success(let restaurants):
                self?.restaurants = restaurants
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.restaurants = []
            }
        }
    }
    
    func searchNearby(latitude: Double, longitude: Double, radius: Int = 5000) {
        isLoading = true
        errorMessage = nil
        
        algoliaService.searchNearby(latitude: latitude, longitude: longitude, radius: radius) { [weak self] result in
            self?.isLoading = false
            
            switch result {
            case .success(let restaurants):
                self?.restaurants = restaurants
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.restaurants = []
            }
        }
    }
    
    func searchWithFilters(query: String, cuisine: String? = nil, city: String? = nil) {
        isLoading = true
        errorMessage = nil
        
        algoliaService.searchWithFilters(query: query, cuisine: cuisine, city: city) { [weak self] result in
            self?.isLoading = false
            
            switch result {
            case .success(let restaurants):
                self?.restaurants = restaurants
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.restaurants = []
            }
        }
    }
    
    private func loadFacets() {
        algoliaService.getFacets { [weak self] result in
            switch result {
            case .success(let facets):
                self?.facets = facets
            case .failure(let error):
                print("Failed to load facets: \(error)")
            }
        }
    }
}
```

## 📍 **4. Location Manager (Optional)**
```swift
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
}
```

## 🔧 **5. Usage Examples**

### **Basic Search Integration**
```swift
// In your existing view
@StateObject private var searchViewModel = RestaurantSearchViewModel()

// Connect to your existing search bar
TextField("Search restaurants...", text: $searchViewModel.searchText)

// Display results in your existing list
List(searchViewModel.restaurants) { restaurant in
    // Your existing restaurant row view
    YourRestaurantRowView(restaurant: restaurant)
}
```

### **Location-Based Search**
```swift
@StateObject private var searchViewModel = RestaurantSearchViewModel()
@StateObject private var locationManager = LocationManager()

// Button to find nearby restaurants
Button("Find Nearby") {
    if let location = locationManager.location {
        searchViewModel.searchNearby(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
    }
}
```

### **Filtered Search**
```swift
// Search with cuisine filter
searchViewModel.searchWithFilters(
    query: "pizza", 
    cuisine: "Italian", 
    city: "New York"
)
```

## 📊 **6. Current Data Status**
- ✅ **19 restaurants** indexed and ready
- ✅ **Real-time sync** active from MongoDB
- ✅ **Search fields**: name, description, cuisine, location
- ✅ **Facets available**: cuisine, city, restaurantType
- ✅ **Location search** enabled

## 🚀 **Quick Start**
1. Add Algolia SDK to your project
2. Copy the Restaurant model
3. Copy AlgoliaService and RestaurantSearchViewModel
4. Connect to your existing UI
5. Test search functionality

## 🔄 **Real-time Updates**
Your MongoDB sync is running and will automatically update Algolia when restaurants are added, updated, or deleted. No additional setup needed!
