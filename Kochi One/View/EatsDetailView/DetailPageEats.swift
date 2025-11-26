//
//  DetailPageEats.swift
//  Kochi One
//
//  Created on 26/11/25.
//

import SwiftUI

struct DetailPageEats: View {
    let restaurant: Restaurant
    @ObservedObject var locationService: LocationService
    let onBack: () -> Void
    @ObservedObject private var favouritesManager = FavouritesManager.shared
    @State private var showCallDialog = false
    @State private var showMapPicker = false
    @State private var showEmailDialog = false
    @State private var showWebsiteDialog = false
    @State private var showShareDialog = false
    @State private var heartScale: CGFloat = 1.0
    
    var operatingHours: OperatingHours {
        restaurant.operatingHours
    }
    
    var body: some View {
        let days: [(String, DayHours)] = [
            ("Monday", operatingHours.monday),
            ("Tuesday", operatingHours.tuesday),
            ("Wednesday", operatingHours.wednesday),
            ("Thursday", operatingHours.thursday),
            ("Friday", operatingHours.friday),
            ("Saturday", operatingHours.saturday),
            ("Sunday", operatingHours.sunday)
        ]
        let todayData = TimeHelper.getTodayHours(from: operatingHours)
        let distance = locationService.calculateDistance(to: restaurant)
        
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Background Image
                    RestaurantHeaderImage(imageURL: restaurant.coverImages.first?.url)
                    
                    // Restaurant Info Content (moved from card)
                    RestaurantInfoContent(
                        restaurant: restaurant,
                        distance: distance,
                        todayData: todayData,
                        convertTo12Hour: TimeHelper.convertTo12Hour,
                        showCallDialog: $showCallDialog,
                        showMapPicker: $showMapPicker,
                        showEmailDialog: $showEmailDialog,
                        showWebsiteDialog: $showWebsiteDialog
                    )
                    
                    // Rating & Ranking Section
                    RatingSection(rating: restaurant.rating, ranking: restaurant.ranking)
                    
                    // Cuisine Section
                    CuisineSection(cuisines: restaurant.cuisine)
                    
                    // Features Section
                    FeaturesSection(features: restaurant.features)
                    
                    // Gallery Section
                    VStack {
                        GallerySection(coverImages: restaurant.coverImages)
                        
                        // Operating Hours and Contact Info
                        VStack(alignment: .leading) {
                            OperatingHoursSection(
                                days: days,
                                todayData: todayData,
                                convertTo12Hour: TimeHelper.convertTo12Hour
                            )
                            
                            ContactInfoSection(restaurant: restaurant)
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 100) // Extra padding for floating buttons
                }
            }
            .ignoresSafeArea(edges: .top)
            
            // Floating buttons at the bottom
            BottomActionButtons(
                restaurant: restaurant,
                onBack: onBack,
                favouritesManager: favouritesManager,
                showShareDialog: $showShareDialog,
                heartScale: $heartScale,
                shareRestaurant: {
                    ShareHelper.shareRestaurant(restaurant)
                }
            )
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    
}
