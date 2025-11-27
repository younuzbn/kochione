//
//  RatingSection.swift
//  Kochi One
//
//  Created on 26/11/25.
//

import SwiftUI

struct RatingSection: View {
    let rating: Double
    let ranking: Int
    
    var body: some View {
        VStack(spacing: 0) {
            // Divider line
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
                .padding(.horizontal, 30)
            
            HStack(spacing: 0) {
                // Rating Display
                VStack(spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(String(format: "%.1f", rating))
                            .font(.system(size: 32, weight: .light, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Image(systemName: "star.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.yellow)
                            .offset(y: -2)
                    }
                    
                    Text("Rating")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.secondary)
                        .tracking(0.5)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                
                // Vertical divider
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 1)
                    .padding(.vertical, 16)
                
                // Ranking Display
                VStack(spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("#\(ranking)")
                            .font(.system(size: 32, weight: .light, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .yellow],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .offset(y: -2)
                    }
                    
                    Text("Top \(ranking) in Kochi One")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.secondary)
                        .tracking(0.5)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            }
            .padding(.horizontal, 30)
            
            // Divider line
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
                .padding(.horizontal, 30)
        }
//        .padding(.vertical, 20)
    }
}

