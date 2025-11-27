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
                    // Background Image with Overlay Info
                    ZStack(alignment: .bottomLeading) {
                        RestaurantHeaderImage(imageURL: restaurant.coverImages.first?.url)
                        
                        // Black gradient overlay at bottom
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.6)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 300)
                        .clipShape(BottomRoundedRectangle(cornerRadius: 20))
                        .allowsHitTesting(false)
                        
                        // Restaurant Info Content overlaid on banner
                        RestaurantInfoContent(
                            restaurant: restaurant,
                            distance: distance,
                            todayData: todayData,
                            convertTo12Hour: TimeHelper.convertTo12Hour
                        )
                        .padding(.horizontal, 30)
                        .padding(.bottom, 20)
                    }
                    
                    // Rating & Ranking Section
                    RatingSection(rating: restaurant.rating, ranking: restaurant.ranking)
                    
                    // Gallery Section
                    GallerySection(coverImages: restaurant.coverImages)
                    
                    // Cuisine Section
                    
                    if !restaurant.cuisine.isEmpty {
                        HStack {
                            Text("Cuisine")
                                .font(.system(size: 20, weight: .semibold))
                            
                            Spacer()
                            
                            // Menu Button
                            
                            NavigationLink {
                                MenuHome()
                                
                                
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "fork.knife")
                                        .font(.system(size: 14, weight: .medium))
                                    Text("View Menu")
                                        .font(.system(size: 15, weight: .semibold))
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundStyle(.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .overlay(
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundStyle(.black),
                                    alignment: .bottom
                                )
                            }
                            
                        }
                        .padding(.horizontal,30)
                        
                        CuisineSection(cuisines: restaurant.cuisine, website: restaurant.contact.website)
                    }
                    
                    // Updates Section
                    UpdatesSection(updates: {
                        var updates: [UpdateItem] = []
                        let allImages = restaurant.coverImages.compactMap { $0.url }
                        
                        if !allImages.isEmpty {
                            // First update with first 3 images
                            let firstImages = Array(allImages.prefix(3))
                            updates.append(UpdateItem(
                                id: "1",
                                title: "New Menu Items Available",
                                description: "We've added exciting new dishes to our menu. Try our chef's special recommendations and experience the latest culinary innovations.",
                                images: firstImages
                            ))
                            
                            // Second update with next 3 images (if available)
                            if allImages.count > 3 {
                                let secondImages = Array(allImages.dropFirst(3).prefix(3))
                                updates.append(UpdateItem(
                                    id: "2",
                                    title: "Weekend Special Offer",
                                    description: "Join us this weekend for special discounts on selected items. Don't miss out on our limited-time offers and seasonal favorites.",
                                    images: secondImages
                                ))
                            }
                        } else {
                            // Fallback updates with no images
                            updates.append(UpdateItem(
                                id: "1",
                                title: "New Menu Items Available",
                                description: "We've added exciting new dishes to our menu. Try our chef's special recommendations and experience the latest culinary innovations.",
                                images: []
                            ))
                        }
                        
                        return updates
                    }())
                    
                    // Features Section
                    FeaturesSection(features: restaurant.features)
                    
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
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    Capsule()
                                        .stroke(Color.black, lineWidth: 1)
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
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    Capsule()
                                        .stroke(Color.black, lineWidth: 1)
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
