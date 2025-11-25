//
//  FavouritesView.swift
//  Kochi One
//
//  Created on 01/10/2025.
//

import SwiftUI

struct FavouritesView: View {
    @ObservedObject private var favouritesManager = FavouritesManager.shared
    @StateObject private var restaurantService = RestaurantService()
    @StateObject private var locationService = LocationService()
    @State private var showDetail = false
    @State private var selectedRestaurant: Restaurant?
    @State private var selectedRestaurantName: String?
    
    // Get favourite restaurants from the service
    private var favouriteRestaurants: [Restaurant] {
        let favouriteIDs = favouritesManager.getFavouriteIDs()
        return restaurantService.restaurants.filter { favouriteIDs.contains($0.id) }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                // Add spacing below navigation title
                Spacer()
                    .frame(height: 12)
                
                if restaurantService.isLoading {
                    VStack {
                        ProgressView("Loading favourites...")
                            .padding()
                    }
                } else if favouriteRestaurants.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No Favourites Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Tap the heart icon on restaurants to add them to your favourites")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 100)
                } else {
                    ForEach(favouriteRestaurants) { restaurant in
                        EatsViewFull(showDetail: $showDetail, restaurant: restaurant, locationService: locationService)
                            .onTapGesture {
                                print("Favourite restaurant tapped: \(restaurant.name)")
                                selectedRestaurant = restaurant
                                selectedRestaurantName = restaurant.name
                                showDetail = true
                            }
                        
                        // Add a subtle separator between posts
                        Divider()
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                    }
                }
            }
        }
        .navigationTitle("My Favourites")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showDetail) {
            if let restaurant = selectedRestaurant {
                EatsDetailView(restaurant: restaurant, locationService: locationService) {
                    // Back button action
                    showDetail = false
                    selectedRestaurant = nil
                    selectedRestaurantName = nil
                }
            }
        }
        .onAppear {
            // Only fetch if we don't have data yet
            if restaurantService.restaurants.isEmpty && !restaurantService.isLoading {
                restaurantService.fetchRestaurants()
            }
        }
    }
}

