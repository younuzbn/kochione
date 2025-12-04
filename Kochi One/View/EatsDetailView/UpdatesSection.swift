//
//  UpdatesSection.swift
//  Kochi One
//
//  Created on 26/11/25.
//

import SwiftUI

struct UpdateItem: Identifiable {
    let id: String
    let title: String
    let description: String
    let images: [String] // Image names from assets or URLs
}

struct UpdatesSection: View {
    let updates: [UpdateItem]
    @State private var currentImageIndices: [String: Int] = [:]
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if !updates.isEmpty {
            VStack(spacing: 0) {
                // Divider line
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 1)
                    .padding(.horizontal, 30)
                
                VStack(alignment: .leading, spacing: 20) {
                    // Updates list
                    VStack(spacing: 20) {
                        ForEach(updates) { update in
                            VStack(alignment: .leading, spacing: 4) {
                                // Title
                                Text(update.title)
                                    .font(.headline)
                                    .lineLimit(1)
                                
                                // Description
                                Text(update.description)
                                    .font(.subheadline)
                                    .lineLimit(4)
                                    .padding(.top, 10)
                                    .padding(.bottom, 20)
                                
                                // Swipeable single image carousel
                                if !update.images.isEmpty {
                                    TabView(selection: Binding(
                                        get: { currentImageIndices[update.id] ?? 0 },
                                        set: { currentImageIndices[update.id] = $0 }
                                    )) {
                                        ForEach(Array(update.images.enumerated()), id: \.offset) { index, imageName in
                                            // Check if it's a URL or asset name
                                            if imageName.hasPrefix("http://") || imageName.hasPrefix("https://") {
                                                AsyncImage(url: URL(string: imageName)) { phase in
                                                    switch phase {
                                                    case .empty:
                                                        Rectangle()
                                                            .fill(Color.gray.opacity(0.1))
                                                            .frame(height: 200)
                                                            .overlay(ProgressView())
                                                    case .success(let image):
                                                        image
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                            .frame(height: 200)
                                                            .clipped()
                                                    case .failure:
                                                        Rectangle()
                                                            .fill(Color.gray.opacity(0.1))
                                                            .frame(height: 200)
                                                            .overlay(Image(systemName: "photo").foregroundStyle(.gray))
                                                    @unknown default:
                                                        EmptyView()
                                                    }
                                                }
                                                .tag(index)
                                            } else {
                                                Image(imageName)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(height: 200)
                                                    .clipped()
                                                    .tag(index)
                                            }
                                        }
                                    }
                                    .tabViewStyle(.page)
                                    .frame(height: 200)
                                    .onAppear {
                                        // Configure page control appearance - theme-aware colors
                                        UIPageControl.appearance().currentPageIndicatorTintColor = colorScheme == .dark ? UIColor.white : UIColor.black
                                        UIPageControl.appearance().pageIndicatorTintColor = colorScheme == .dark ? UIColor.white.withAlphaComponent(0.3) : UIColor.black.withAlphaComponent(0.3)
                                    }
                                    .onChange(of: colorScheme) { oldValue, newValue in
                                        // Update colors when theme changes
                                        UIPageControl.appearance().currentPageIndicatorTintColor = newValue == .dark ? UIColor.white : UIColor.black
                                        UIPageControl.appearance().pageIndicatorTintColor = newValue == .dark ? UIColor.white.withAlphaComponent(0.3) : UIColor.black.withAlphaComponent(0.3)
                                    }
                                } else {
                                    // Placeholder when no images
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(height: 200)
                                        .overlay(Image(systemName: "photo").foregroundStyle(.gray))
                                }
                            }
                            .padding(.horizontal, 30)
                            
                            // Divider between items (except last)
                            if update.id != updates.last?.id {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(height: 1)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 10)
                            }
                        }
                    }
                }
                .padding(.vertical, 20)
            }
        }
    }
}

