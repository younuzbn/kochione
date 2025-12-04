//
//  FeaturesSection.swift
//  Kochi One
//
//  Created on 26/11/25.
//

import SwiftUI

struct FeaturesSection: View {
    let features: [String]
    
    // Map feature names to SF Symbols
    private func icon(for feature: String) -> String {
        let lowercased = feature.lowercased()
        switch lowercased {
        case "delivery":
            return "bicycle"
        case "takeout", "take-out", "take out":
            return "bag.fill"
        case "dine-in", "dine in":
            return "fork.knife"
        case "outdoor seating", "outdoor":
            return "sun.max.fill"
        case "parking":
            return "car.fill"
        case "wifi", "wi-fi":
            return "wifi"
        case "live music":
            return "music.note"
        case "bar":
            return "wineglass.fill"
        case "reservations":
            return "calendar"
        case "wheelchair accessible", "accessible":
            return "figure.roll"
        default:
            return "checkmark.circle.fill"
        }
    }
    
    var body: some View {
        if !features.isEmpty {
            VStack(spacing: 0) {

                // Divider line
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 1)

                    .padding(.horizontal, 30)

                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Features")
                        .font(.system(size: 20, weight: .semibold))
                        .padding(.horizontal, 30)
                    
                    // Features list - clean vertical layout
                    VStack(spacing: 10) {
                        ForEach(features, id: \.self) { feature in
                            HStack(spacing: 14) {
                                Image(systemName: icon(for: feature))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 24, alignment: .leading)
                                
                                Text(feature)
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 30)
                            .padding(.vertical, 10)
                            
                            // Divider between items (except last)
                            if feature != features.last {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(height: 1)
                                    .padding(.leading, 68) // Align with text (30 + 24 + 14)
                            }
                        }
                    }
                }
                .padding(.vertical, 30)
                
                // Divider line
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 1)
                    .padding(.horizontal, 30)
            }
        }
    }
}

