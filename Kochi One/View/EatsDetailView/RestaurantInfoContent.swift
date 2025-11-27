//
//  RestaurantInfoContent.swift
//  Kochi One
//
//  Created on 26/11/25.
//

import SwiftUI

struct RestaurantInfoContent: View {
    let restaurant: Restaurant
    let distance: String
    let todayData: (hours: DayHours, isOpen: Bool)
    let convertTo12Hour: (String) -> String
    
    var body: some View {
        VStack(spacing: 0) {
            // Part 1: Logo, Name, and Open/Close Status
            HStack(alignment: .center, spacing: 16) {
                // Logo - Round, Left side
                if let logoURL = restaurant.logo?.url, let url = URL(string: logoURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Circle()
                                .fill(Color.white.opacity(0.9))
                                .frame(width: 70, height: 70)
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 70, height: 70)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        case .failure:
                            Circle()
                                .fill(Color.white.opacity(0.9))
                                .frame(width: 70, height: 70)
                                .overlay(Image(systemName: "photo").foregroundStyle(.gray))
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 70, height: 70)
                        .overlay(Image(systemName: "photo").foregroundStyle(.gray))
                }
                
                // Name and Open/Close Status
                VStack(alignment: .leading, spacing: 6) {
                    Text(restaurant.name)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    
                    // Open/Close Status
                    HStack(spacing: 6) {
                        Circle()
                            .fill(todayData.isOpen ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        
                        if todayData.isOpen {
                            Text("Open")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            Text("until \(convertTo12Hour(todayData.hours.close ?? ""))")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        } else {
                            Text("Closed")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        }
                    }
                }
                
                Spacer()
            }
        }
    }
}

