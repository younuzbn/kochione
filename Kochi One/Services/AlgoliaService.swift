//import Foundation
//import AlgoliaSearchClient
//import Combine
//
//class AlgoliaService: ObservableObject {
//    private let client: SearchClient
//    private let index: Index
//    
//    // Published properties for ObservableObject conformance
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//    
//    init() {
//        let appId = ApplicationID(rawValue: "EMTYPLB75P")
//        let apiKey = APIKey(rawValue: "8c302496ed4629f956ceb19864f95733")
//        let indexName = IndexName(rawValue: "restaurants_index")
//        
//        self.client = SearchClient(appID: appId, apiKey: apiKey)
//        self.index = client.index(withName: indexName)
//    }
//    
//    // Basic text search
//    func search(query: String, completion: @escaping (Result<[Restaurant], Error>) -> Void) {
//        isLoading = true
//        errorMessage = nil
//        
//        let searchQuery = Query()
//            .set(\.query, to: query)
//            .set(\.hitsPerPage, to: 20)
//            .set(\.attributesToRetrieve, to: [
//                "objectID", "name", "description", "cuisine", 
//                "rating", "restaurantType", "city", "state", 
//                "country", "latitude", "longitude", "logoUrl",
//                "features", "isActive", "ranking", "phone", "email"
//            ])
//        
//        index.search(query: searchQuery) { result in
//            DispatchQueue.main.async {
//                self.isLoading = false
//                switch result {
//                case .success(let response):
//                    let restaurants = response.hits.compactMap { hit in
//                        self.convertAlgoliaHitToRestaurant(hit)
//                    }
//                    completion(.success(restaurants))
//                case .failure(let error):
//                    self.errorMessage = error.localizedDescription
//                    completion(.failure(error))
//                }
//            }
//        }
//    }
//    
//    // Location-based search
//    func searchNearby(latitude: Double, longitude: Double, radius: Int = 5000, completion: @escaping (Result<[Restaurant], Error>) -> Void) {
//        isLoading = true
//        errorMessage = nil
//        
//        let searchQuery = Query()
//            .set(\.aroundLatLng, to: Point(latitude: latitude, longitude: longitude))
//            .set(\.aroundRadius, to: .meters(radius))
//            .set(\.hitsPerPage, to: 20)
//        
//        index.search(query: searchQuery) { result in
//            DispatchQueue.main.async {
//                self.isLoading = false
//                switch result {
//                case .success(let response):
//                    let restaurants = response.hits.compactMap { hit in
//                        self.convertAlgoliaHitToRestaurant(hit)
//                    }
//                    completion(.success(restaurants))
//                case .failure(let error):
//                    self.errorMessage = error.localizedDescription
//                    completion(.failure(error))
//                }
//            }
//        }
//    }
//    
//    // Search with filters
//    func searchWithFilters(query: String, cuisine: String? = nil, city: String? = nil, completion: @escaping (Result<[Restaurant], Error>) -> Void) {
//        let searchQuery = Query()
//            .set(\.query, to: query)
//        
//        var filters: [String] = []
//        if let cuisine = cuisine {
//            filters.append("cuisine:'\(cuisine)'")
//        }
//        if let city = city {
//            filters.append("city:'\(city)'")
//        }
//        
//        if !filters.isEmpty {
//            let filteredQuery = searchQuery.set(\.filters, to: filters.joined(separator: " AND "))
//            index.search(query: filteredQuery) { result in
//                DispatchQueue.main.async {
//                    self.isLoading = false
//                    switch result {
//                    case .success(let response):
//                        let restaurants = response.hits.compactMap { hit in
//                            self.convertAlgoliaHitToRestaurant(hit)
//                        }
//                        completion(.success(restaurants))
//                    case .failure(let error):
//                        self.errorMessage = error.localizedDescription
//                        completion(.failure(error))
//                    }
//                }
//            }
//        } else {
//            search(query: query) { result in
//                completion(result)
//            }
//        }
//    }
//    
//    // Get facets for filtering
//    func getFacets(completion: @escaping (Result<[String: [String]], Error>) -> Void) {
//        isLoading = true
//        errorMessage = nil
//        
//        let searchQuery = Query()
//            .set(\.facets, to: ["cuisine", "city", "restaurantType"])
//            .set(\.hitsPerPage, to: 0)
//        
//        index.search(query: searchQuery) { result in
//            DispatchQueue.main.async {
//                self.isLoading = false
//                switch result {
//                case .success(let response):
//                    var facets: [String: [String]] = [:]
//                    if let responseFacets = response.facets {
//                        for (attribute, facetList) in responseFacets {
//                            facets[attribute.rawValue] = facetList.map { $0.value }
//                        }
//                    }
//                    completion(.success(facets))
//                case .failure(let error):
//                    self.errorMessage = error.localizedDescription
//                    completion(.failure(error))
//                }
//            }
//        }
//    }
//    
//    // Convert Algolia hit to Restaurant model
//    private func convertAlgoliaHitToRestaurant(_ hit: Hit<JSON>) -> Restaurant? {
//        do {
//            let hitData = hit.object
//            
//            // Extract basic info using proper JSON handling
//            guard let objectID = hitData["objectID"]?.string,
//                  let name = hitData["name"]?.string,
//                  let description = hitData["description"]?.string,
//                  let latitude = hitData["latitude"]?.double,
//                  let longitude = hitData["longitude"]?.double else {
//                return nil
//            }
//            
//            // Extract optional fields with defaults
//            let cuisine = hitData["cuisine"]?.array?.compactMap { $0.string } ?? []
//            let features = hitData["features"]?.array?.compactMap { $0.string } ?? []
//            let rating = hitData["rating"]?.double ?? 0.0
//            let ranking = hitData["ranking"]?.int ?? 0
//            let isActive = hitData["isActive"]?.bool ?? true
//            let restaurantType = hitData["restaurantType"]?.string
//            let phone = hitData["phone"]?.string ?? ""
//            let email = hitData["email"]?.string ?? ""
//            let city = hitData["city"]?.string ?? ""
//            let state = hitData["state"]?.string ?? ""
//            let country = hitData["country"]?.string ?? ""
//            let logoUrl = hitData["logoUrl"]?.string
//            
//            // Create Restaurant object
//            let restaurant = Restaurant(
//                id: objectID,
//                bizId: objectID, // Using objectID as bizId for Algolia results
//                name: name,
//                description: description,
//                logo: logoUrl != nil ? RestaurantLogo(
//                    url: logoUrl,
//                    key: nil,
//                    originalName: nil,
//                    size: nil,
//                    uploadedAt: ""
//                ) : nil,
//                coverImages: [], // Algolia doesn't have cover images in this structure
//                address: RestaurantAddress(
//                    street: "",
//                    city: city,
//                    state: state,
//                    zipCode: "",
//                    country: country
//                ),
//                location: RestaurantLocation(
//                    latitude: latitude,
//                    longitude: longitude
//                ),
//                contact: RestaurantContact(
//                    phone: phone,
//                    email: email,
//                    website: nil
//                ),
//                cuisine: cuisine,
//                features: features,
//                rating: rating,
//                ranking: ranking,
//                operatingHours: OperatingHours(
//                    monday: DayHours(open: nil, close: nil, closed: false),
//                    tuesday: DayHours(open: nil, close: nil, closed: false),
//                    wednesday: DayHours(open: nil, close: nil, closed: false),
//                    thursday: DayHours(open: nil, close: nil, closed: false),
//                    friday: DayHours(open: nil, close: nil, closed: false),
//                    saturday: DayHours(open: nil, close: nil, closed: false),
//                    sunday: DayHours(open: nil, close: nil, closed: false)
//                ),
//                isActive: isActive,
//                owner: nil,
//                images: [],
//                restaurantType: restaurantType,
//                createdAt: "",
//                updatedAt: "",
//                v: 0
//            )
//            
//            return restaurant
//            
//        } catch {
//            print("Error converting Algolia hit to Restaurant: \(error)")
//            return nil
//        }
//    }
//}
