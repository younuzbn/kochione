//
//  FavouritesManager.swift
//  Kochi One
//
//  Created on 01/10/2025.
//

import Foundation
internal import Combine

class FavouritesManager: ObservableObject {
    static let shared = FavouritesManager()
    
    @Published var favouriteRestaurantIDs: Set<String> = []
    
    private let favouritesKey = "favouriteRestaurantIDs"
    
    private init() {
        loadFavourites()
    }
    
    // Load favourites from UserDefaults
    private func loadFavourites() {
        if let data = UserDefaults.standard.data(forKey: favouritesKey),
           let ids = try? JSONDecoder().decode(Set<String>.self, from: data) {
            favouriteRestaurantIDs = ids
        }
    }
    
    // Save favourites to UserDefaults
    private func saveFavourites() {
        if let data = try? JSONEncoder().encode(favouriteRestaurantIDs) {
            UserDefaults.standard.set(data, forKey: favouritesKey)
        }
    }
    
    // Toggle favourite status
    func toggleFavourite(restaurantID: String) {
        if favouriteRestaurantIDs.contains(restaurantID) {
            favouriteRestaurantIDs.remove(restaurantID)
        } else {
            favouriteRestaurantIDs.insert(restaurantID)
        }
        saveFavourites()
    }
    
    // Check if restaurant is favourited
    func isFavourite(restaurantID: String) -> Bool {
        return favouriteRestaurantIDs.contains(restaurantID)
    }
    
    // Get all favourite restaurant IDs
    func getFavouriteIDs() -> [String] {
        return Array(favouriteRestaurantIDs)
    }
}

