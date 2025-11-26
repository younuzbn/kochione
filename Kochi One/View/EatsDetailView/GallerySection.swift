//
//  GallerySection.swift
//  Kochi One
//
//  Created on 26/11/25.
//

import SwiftUI

struct GallerySection: View {
    let coverImages: [RestaurantImage]
    
    // Calculate image width: (screen width - left padding - spacing between images) / 3
    private var imageWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let leftPadding: CGFloat = 30 // Align with other sections
        let spacing: CGFloat = 20 // 10px spacing between 3 images (2 gaps)
        return (screenWidth - leftPadding - spacing) / 3
    }
    
    // Image height should be less than width (landscape/rectangle)
    private var imageHeight: CGFloat {
        return imageWidth * 0.75 // 4:3 aspect ratio (width > height)
    }
    
    var body: some View {
        if !coverImages.dropFirst().isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(coverImages.dropFirst().enumerated()), id: \.offset) { index, media in
                        if let url = URL(string: media.url) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: imageWidth, height: imageHeight)
                                        .overlay(ProgressView())
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: imageWidth, height: imageHeight)
                                        .clipped()
                                        .cornerRadius(12)
                                case .failure:
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: imageWidth, height: imageHeight)
                                        .overlay(
                                            VStack(spacing: 8) {
                                                Image(systemName: "photo")
                                                    .font(.system(size: 24))
                                                    .foregroundStyle(.gray)
                                                Text("No Image")
                                                    .font(.system(size: 12))
                                                    .foregroundStyle(.gray)
                                            }
                                        )
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                    // Add trailing padding to match the right side
                    Spacer()
                        .frame(width: 30)
                }
            }
            .padding(.vertical, 15)
        }
    }
}

