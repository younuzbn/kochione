//
//  TopActionButtons.swift
//  Kochi One
//
//  Created on 26/11/25.
//

import SwiftUI

struct BottomActionButtons: View {
    let restaurant: Restaurant
    let onBack: () -> Void
    @ObservedObject var favouritesManager: FavouritesManager
    @Binding var showShareDialog: Bool
    @Binding var heartScale: CGFloat
    let shareRestaurant: () -> Void
    @Binding var showCallDialog: Bool
    @Binding var showMapPicker: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            //MARK: BACK BTN
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Color.primary)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            
            //MARK: LIKE BTN
            Button {
                // Toggle favourite with animation
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    heartScale = 1.3
                }
                
                // Toggle favourite
                favouritesManager.toggleFavourite(restaurantID: restaurant.id)
                
                // Reset scale after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        heartScale = 1.0
                    }
                }
            } label: {
                Image(systemName: favouritesManager.isFavourite(restaurantID: restaurant.id) ? "suit.heart.fill" : "suit.heart")
                    .foregroundStyle(favouritesManager.isFavourite(restaurantID: restaurant.id) ? Color.red : Color.primary)
                    .font(.system(size: 18, weight: .medium))
                    .scaleEffect(heartScale)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            
            //MARK: CALL BTN
            Button {
                showCallDialog = true
            } label: {
                Image(systemName: "phone.fill")
                    .foregroundStyle(Color.primary)
                    .font(.system(size: 18, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .confirmationDialog("Call \(restaurant.name)?", isPresented: $showCallDialog, titleVisibility: .visible) {
                Button("Call") {
                    let phoneNumber = restaurant.contact.phone
                    guard !phoneNumber.isEmpty else {
                        print("Phone number is empty")
                        return
                    }
                    
                    let cleanedNumber = phoneNumber
                        .replacingOccurrences(of: " ", with: "")
                        .replacingOccurrences(of: "-", with: "")
                        .replacingOccurrences(of: "(", with: "")
                        .replacingOccurrences(of: ")", with: "")
                        .replacingOccurrences(of: ".", with: "")
                    
                    if let phoneURL = URL(string: "tel://\(cleanedNumber)") {
                        if UIApplication.shared.canOpenURL(phoneURL) {
                            UIApplication.shared.open(phoneURL)
                        }
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(restaurant.contact.phone.isEmpty ? "No phone number available" : restaurant.contact.phone)
            }
            
            //MARK: NAVIGATION BTN
            Button {
                let availableApps = MapApp.availableApps()
                if availableApps.count == 1, let app = availableApps.first {
                    if let url = app.navigationURL(latitude: restaurant.location.latitude, longitude: restaurant.location.longitude, businessName: restaurant.name) {
                        UIApplication.shared.open(url)
                    }
                } else {
                    showMapPicker = true
                }
            } label: {
                Image(systemName: "location.fill")
                    .foregroundStyle(Color.primary)
                    .font(.system(size: 18, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .confirmationDialog("Choose Navigation App", isPresented: $showMapPicker, titleVisibility: .visible) {
                ForEach(MapApp.availableApps()) { app in
                    Button(app.rawValue) {
                        if let url = app.navigationURL(latitude: restaurant.location.latitude, longitude: restaurant.location.longitude, businessName: restaurant.name) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
            
            //MARK: SHARE BTN
            Button {
                showShareDialog = true
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(Color.primary)
                    .font(.system(size: 18, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .confirmationDialog("", isPresented: $showShareDialog, titleVisibility: .hidden) {
                Button("Share") {
                    shareRestaurant()
                }
                
                Button("Report") {
                    print("Report restaurant: \(restaurant.name)")
                }
                
                if let website = restaurant.contact.website, !website.isEmpty {
                    Button("View Menu") {
                        let urlString = website.hasPrefix("http") ? website : "https://\(website)"
                        if let url = URL(string: urlString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                
                Button("Cancel", role: .cancel) { }
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal, 30)
        .padding(.bottom, 34)
        .padding(.top, 16)
    }
}

