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
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 70, height: 70)
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 70, height: 70)
                                .clipShape(Circle())
                        case .failure:
                            Circle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 70, height: 70)
                                .overlay(Image(systemName: "photo").foregroundStyle(.gray))
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 70, height: 70)
                        .overlay(Image(systemName: "photo").foregroundStyle(.gray))
                }
                
                // Name and Open/Close Status
                VStack(alignment: .leading, spacing: 6) {
                    Text(restaurant.name)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    // Open/Close Status
                    HStack(spacing: 6) {
                        Circle()
                            .fill(todayData.isOpen ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        
                        if todayData.isOpen {
                            Text("Open")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.green)
                            Text("until \(convertTo12Hour(todayData.hours.close ?? ""))")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Closed")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.red)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            .padding(.bottom, 20)
            
            // Divider
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
                .padding(.horizontal, 30)
            
            // Part 2: Address and Distance
            VStack(alignment: .leading, spacing: 12) {
                // Address
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "mappin")
                        .font(.system(size: 14))
                        .foregroundStyle(.blue)
                        .frame(width: 20)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(restaurant.address.street)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(.primary)
                        Text("\(restaurant.address.city), \(restaurant.address.state)")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Distance - Below address, no icon
                HStack {
                    Text("\(distance) away from you")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                .padding(.leading, 30)
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
            
            // Divider removed - no action buttons in this section
        }
        .background()
    }
}

