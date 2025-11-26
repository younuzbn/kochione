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
        NavigationStack{
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
                        convertTo12Hour: TimeHelper.convertTo12Hour
                    )
                    
                    // Rating & Ranking Section
                    RatingSection(rating: restaurant.rating, ranking: restaurant.ranking)
                    
                    // Cuisine Section
                    
                    if !restaurant.cuisine.isEmpty {
                        HStack {
                            Text("Cuisine")
                                .font(.system(size: 20, weight: .semibold))
                            
                            Spacer()
                            
                            // Menu Button
                            
                            NavigationLink {
                                Home()
                                
                                
                            } label: {
                                HStack(spacing: 6) {
                                    //                                        Image(systemName: "book.fill")
                                    //                                            .font(.system(size: 14, weight: .medium))
                                    Text("Menu")
                                        .font(.system(size: 15, weight: .semibold))
                                }
                                .foregroundStyle(.blue)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.blue.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            
                        }
                        .padding(.horizontal,30)
                        
                        CuisineSection(cuisines: restaurant.cuisine, website: restaurant.contact.website)
                    }
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
                    
                    // Website and Email Section at the bottom
                    VStack(spacing: 12) {
                        // Visit Website Button
                        if let website = restaurant.contact.website, !website.isEmpty {
                            Button {
                                let urlString = website.hasPrefix("http") ? website : "https://\(website)"
                                if let url = URL(string: urlString) {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "safari")
                                        .font(.system(size: 16, weight: .medium))
                                    Text("Visit Website")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    Capsule()
                                        .fill(Color.blue)
                                )
                            }
                        }
                        
                        // Email Button
                        if !restaurant.contact.email.isEmpty {
                            Button {
                                if let emailURL = URL(string: "mailto:\(restaurant.contact.email)") {
                                    if UIApplication.shared.canOpenURL(emailURL) {
                                        UIApplication.shared.open(emailURL)
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .font(.system(size: 16, weight: .medium))
                                    Text("Email")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    Capsule()
                                        .fill(Color.blue)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
                    .padding(.bottom, 120) // Extra padding for floating buttons
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
                },
                showCallDialog: $showCallDialog,
                showMapPicker: $showMapPicker
            )
        }
        .ignoresSafeArea(edges: .bottom)
    }
    }
    
    
}
