import Foundation
import Combine

class RestaurantService: ObservableObject {
    private let baseURL = "https://codecastle.store/api"
    private var cancellables = Set<AnyCancellable>()
    
    @Published var restaurants: [Restaurant] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchRestaurants() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/restaurants") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: RestaurantResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("❌ Restaurant fetch error: \(error)")
                        if let decodingError = error as? DecodingError {
                            print("❌ Decoding error details: \(decodingError)")
                        }
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] response in
                    print("✅ Successfully fetched \(response.data.restaurants.count) restaurants")
                    self?.restaurants = response.data.restaurants
                }
            )
            .store(in: &cancellables)
    }
    
    func fetchRestaurant(by bizId: String) -> AnyPublisher<Restaurant, Error> {
        guard let url = URL(string: "\(baseURL)/restaurants/biz/\(bizId)") else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: SingleRestaurantResponse.self, decoder: JSONDecoder())
            .map(\.data.restaurant)
            .eraseToAnyPublisher()
    }
}
