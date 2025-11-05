import Foundation

struct Restaurant: Codable, Identifiable {
    let id: String
    let bizId: String
    let name: String
    let description: String
    let logo: RestaurantLogo?
    let coverImages: [RestaurantImage]
    let address: RestaurantAddress
    let location: RestaurantLocation
    let contact: RestaurantContact
    let cuisine: [String]
    let features: [String]
    let rating: Double
    let ranking: Int
    let operatingHours: OperatingHours
    let isActive: Bool
    let owner: String?
    let images: [String]
    let restaurantType: String?
    let createdAt: String
    let updatedAt: String
    let v: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case bizId = "biz_id"
        case name, description, logo, coverImages, address, location, contact, cuisine, features, rating, ranking, operatingHours, isActive, owner, images, restaurantType, createdAt, updatedAt
        case v = "__v"
    }
}

struct RestaurantImage: Codable {
    let url: String
    let key: String
    let originalName: String
    let size: Int
    let uploadedAt: String
    let alt: String?
    let id: String?
    
    enum CodingKeys: String, CodingKey {
        case url, key, originalName, size, uploadedAt, alt
        case id = "_id"
    }
}

struct RestaurantLogo: Codable {
    let url: String?
    let key: String?
    let originalName: String?
    let size: Int?
    let uploadedAt: String
}

struct RestaurantAddress: Codable {
    let street: String
    let city: String
    let state: String
    let zipCode: String
    let country: String
}

struct RestaurantLocation: Codable {
    let latitude: Double
    let longitude: Double
}

struct RestaurantContact: Codable {
    let phone: String
    let email: String
    let website: String?
}

struct OperatingHours: Codable {
    let monday: DayHours
    let tuesday: DayHours
    let wednesday: DayHours
    let thursday: DayHours
    let friday: DayHours
    let saturday: DayHours
    let sunday: DayHours
}

struct DayHours: Codable {
    let open: String?
    let close: String?
    let closed: Bool
}

struct RestaurantResponse: Codable {
    let status: String
    let data: RestaurantData
}

struct RestaurantData: Codable {
    let restaurants: [Restaurant]
}

struct SingleRestaurantResponse: Codable {
    let status: String
    let data: SingleRestaurantData
}

struct SingleRestaurantData: Codable {
    let restaurant: Restaurant
}
