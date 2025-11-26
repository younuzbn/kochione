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
    
    var body: some View {
        HStack(spacing: 0) {
            //MARK: BACK BTN
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Color.primary)
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                    )
            }
            
            Spacer()
            
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
                    .font(.system(size: 20, weight: .medium))
                    .scaleEffect(heartScale)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                    )
            }
            
            Spacer()
            
            //MARK: SHARE BTN
            Button {
                showShareDialog = true
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(Color.primary)
                    .font(.system(size: 20, weight: .medium))
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                    )
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
        .padding(.bottom, 34)
        .padding(.top, 16)
    }
}

