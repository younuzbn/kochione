//import Foundation
//import Combine
//
//class RestaurantSearchViewModel: ObservableObject {
//    @Published var restaurants: [Restaurant] = []
//    @Published var isLoading = false
//    @Published var searchText = ""
//    @Published var errorMessage: String?
//    @Published var facets: [String: [String]] = [:]
//    @Published var isSearching = false
//    
////    private let algoliaService = AlgoliaService()
//    private var cancellables = Set<AnyCancellable>()
//    
//    init() {
//        // Auto-search when text changes (with debounce)
//        $searchText
//            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
//            .removeDuplicates()
//            .sink { [weak self] searchText in
//                if searchText.count >= 2 {
//                    self?.searchRestaurants(query: searchText)
//                } else if searchText.isEmpty {
//                    self?.restaurants = []
//                    self?.isSearching = false
//                }
//            }
//            .store(in: &cancellables)
//        
//        // Load facets on init
//        loadFacets()
//    }
//    
////    func searchRestaurants(query: String) {
////        isLoading = true
////        isSearching = true
////        errorMessage = nil
////        
////        algoliaService.search(query: query) { [weak self] result in
////            self?.isLoading = false
////            
////            switch result {
////            case .success(let restaurants):
////                self?.restaurants = restaurants
////            case .failure(let error):
////                self?.errorMessage = error.localizedDescription
////                self?.restaurants = []
////            }
////        }
////    }
//    
//    func searchNearby(latitude: Double, longitude: Double, radius: Int = 5000) {
//        isLoading = true
//        isSearching = true
//        errorMessage = nil
//        
//        algoliaService.searchNearby(latitude: latitude, longitude: longitude, radius: radius) { [weak self] result in
//            self?.isLoading = false
//            
//            switch result {
//            case .success(let restaurants):
//                self?.restaurants = restaurants
//            case .failure(let error):
//                self?.errorMessage = error.localizedDescription
//                self?.restaurants = []
//            }
//        }
//    }
//    
//    func searchWithFilters(query: String, cuisine: String? = nil, city: String? = nil) {
//        isLoading = true
//        isSearching = true
//        errorMessage = nil
//        
//        algoliaService.searchWithFilters(query: query, cuisine: cuisine, city: city) { [weak self] result in
//            self?.isLoading = false
//            
//            switch result {
//            case .success(let restaurants):
//                self?.restaurants = restaurants
//            case .failure(let error):
//                self?.errorMessage = error.localizedDescription
//                self?.restaurants = []
//            }
//        }
//    }
//    
//    func clearSearch() {
//        searchText = ""
//        restaurants = []
//        isSearching = false
//        errorMessage = nil
//    }
//    
//    private func loadFacets() {
//        algoliaService.getFacets { [weak self] result in
//            switch result {
//            case .success(let facets):
//                self?.facets = facets
//            case .failure(let error):
//                print("Failed to load facets: \(error)")
//            }
//        }
//    }
//}
