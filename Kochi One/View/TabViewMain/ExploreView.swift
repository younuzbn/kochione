//
//  ExploreView.swift
//  Kochi One
//
//  Created by APPLE on 01/10/2025.
//

import SwiftUI
import CoreLocation
import UIKit

// Model for Explore items
struct ExploreItem: Identifiable {
    let id: String
    let title: String
    let description: String
    let location: String
    let distance: String
    let images: [String] // Image names from assets
    let category: String
}

// Reusable Explore Type One View (similar to EatsViewFull)
struct ExploreTypeOne: View {
    @State private var activeID: String?
    @Binding var showDetail: Bool
    let item: ExploreItem
    
    private var imageViewerConfig: ImageViewerConfig {
        ImageViewerConfig(height: 100, cornerRadius: 10, spacing: 5)
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.title)
                            .font(.headline)
                            .lineLimit(1)
                        
                        Spacer()
                    }
                    
                    // Description
                    Text(item.description)
                        .font(.subheadline)
                        .lineLimit(4)
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                    
                    // Image Viewer with snooker images - same design as EatsView (4 images, 2x2 grid)
                    ImageViewer(config: imageViewerConfig) {
                        ForEach(item.images.prefix(4), id: \.self) { imageName in
                            Image(imageName)
                                .resizable()
                                .containerValue(\.activeViewID, imageName)
                        }
                    } overlay: {
                        OverlayViewExplore(activeID: activeID, item: item)
                    } updates: { isPresented, activeID in
                        self.activeID = activeID?.base as? String
                    }
                    
                    // Action buttons
                    HStack {
                        // Message/Comment Button
                        Button {
                            print("Comment button tapped")
                        } label: {
                            Image(systemName: "message")
                        }
                        
                        Spacer()
                        
                        // Repost Button
                        Button {
                            print("Repost button tapped")
                        } label: {
                            Image(systemName: "arrow.trianglehead.bottomleft.capsulepath.clockwise")
                        }
                        
                        Spacer()
                        
                        // Like/Heart Button
                        Button {
                            print("Like button tapped")
                        } label: {
                            Image(systemName: "suit.heart")
                        }
                        
                        Spacer()
                        
                        // Share Button
                        Button {
                            print("Share button tapped")
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                    .foregroundStyle(.primary.secondary)
                    .padding(.top, 10)
                }
                .padding(.top, 10)
            }
            .padding([.leading, .trailing], 15)
            
            Spacer(minLength: 0)
        }
        .contentShape(Rectangle())
    }
}

// Reusable Explore Type Two View (same design as ExploreTypeOne but with swipeable single image)
struct ExploreTypeTwo: View {
    @State private var activeID: String?
    @Binding var showDetail: Bool
    let item: ExploreItem
    @State private var currentImageIndex: Int = 0
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.title)
                            .font(.headline)
                            .lineLimit(1)
                        
                        Spacer()
                    }
                    
                    // Description
                    Text(item.description)
                        .font(.subheadline)
                        .lineLimit(4)
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                    
                    // Swipeable single image carousel
                    TabView(selection: $currentImageIndex) {
                        ForEach(Array(item.images.enumerated()), id: \.offset) { index, imageName in
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .tag(index)
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
                    
                    // Action buttons
                    HStack {
                        // Message/Comment Button
                        Button {
                            print("Comment button tapped")
                        } label: {
                            Image(systemName: "message")
                        }
                        
                        Spacer()
                        
                        // Repost Button
                        Button {
                            print("Repost button tapped")
                        } label: {
                            Image(systemName: "arrow.trianglehead.bottomleft.capsulepath.clockwise")
                        }
                        
                        Spacer()
                        
                        // Like/Heart Button
                        Button {
                            print("Like button tapped")
                        } label: {
                            Image(systemName: "suit.heart")
                        }
                        
                        Spacer()
                        
                        // Share Button
                        Button {
                            print("Share button tapped")
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                    .foregroundStyle(.primary.secondary)
                    .padding(.top, 10)
                }
                .padding(.top, 10)
            }
            .padding([.leading, .trailing], 15)
            
            Spacer(minLength: 0)
        }
        .contentShape(Rectangle())
    }
}

// Overlay View for Explore
struct OverlayViewExplore: View {
    var activeID: String?
    let item: ExploreItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundStyle(.white.secondary)
                    .padding(10)
                    .contentShape(.rect)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay {
                if item.images.contains(where: { $0 == activeID }) {
                    Text(item.title)
                        .font(.callout)
                        .foregroundStyle(.white)
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(15)
    }
}

// Main Explore View
struct ExploreView: View {
    // Dummy data for ExploreTypeOne - need 4 images for 2x2 grid
    @State private var exploreTypeOneItems: [ExploreItem] = [
        ExploreItem(
            id: "1",
            title: "Snooker Championship 2024",
            description: "Join us for the biggest snooker championship of the year. Watch professional players compete for the grand prize. Experience the thrill of precision and strategy.",
            location: "Kochi Sports Complex",
            distance: "2.5 km",
            images: ["snooker", "snooker2", "snooker3", "snooker4"], // 4 images for 2x2 grid
            category: "Sports"
        ),
        ExploreItem(
            id: "2",
            title: "Local Snooker Tournament",
            description: "Community snooker tournament happening this weekend. All skill levels welcome. Come and enjoy a day of competitive snooker with friends and family.",
            location: "Downtown Recreation Center",
            distance: "5.8 km",
            images: ["snooker", "snooker2", "snooker3", "snooker4"], // 4 images for 2x2 grid
            category: "Events"
        )
    ]
    
    // Dummy data for ExploreTypeTwo - swipeable single image
    @State private var exploreTypeTwoItems: [ExploreItem] = [
        ExploreItem(
            id: "3",
            title: "Weekend Snooker Session",
            description: "Join us every weekend for casual snooker sessions. Perfect for beginners and intermediate players. Equipment provided. Book your slot now!",
            location: "City Sports Club",
            distance: "3.2 km",
            images: ["snooker", "snooker2", "snooker3"], // Multiple images for swiping
            category: "Weekly"
        ),
        ExploreItem(
            id: "4",
            title: "Professional Snooker Training",
            description: "Learn from professional coaches. Advanced training sessions for serious players. Improve your technique and strategy with expert guidance.",
            location: "Elite Sports Academy",
            distance: "7.1 km",
            images: ["snooker", "snooker2", "snooker3"], // Multiple images for swiping
            category: "Training"
        )
    ]
    
    @State private var showDetail = false
    @State private var selectedItem: ExploreItem?
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                // Two ExploreTypeOne views
                ForEach(exploreTypeOneItems) { item in
                    ExploreTypeOne(showDetail: $showDetail, item: item)
                        .onTapGesture {
                            print("Explore item tapped: \(item.title)")
                            selectedItem = item
                            showDetail = true
                        }
                    
                    // Add a subtle separator between items
                    Divider()
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                }
                
                // Two ExploreTypeTwo views
                ForEach(exploreTypeTwoItems) { item in
                    ExploreTypeTwo(showDetail: $showDetail, item: item)
                        .onTapGesture {
                            print("Explore item tapped: \(item.title)")
                            selectedItem = item
                            showDetail = true
                        }
                    
                    // Add a subtle separator between items
                    Divider()
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                }
            }
        }
        .fullScreenCover(isPresented: $showDetail) {
            if let item = selectedItem {
                ExploreDetailView(item: item) {
                    showDetail = false
                    selectedItem = nil
                }
            }
        }
    }
}

// Detail View for Explore items
struct ExploreDetailView: View {
    let item: ExploreItem
    let onBack: () -> Void
    
    var body: some View {
        VStack {
            // Header with back button
            HStack {
                Button(action: onBack) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                .foregroundColor(.blue)
                
                Spacer()
            }
            .padding()
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title and basic info
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(.fill)
                            .frame(width: 60, height: 60)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.title)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            HStack {
                                Text(item.distance)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Image(systemName: "location.north.line.fill")
                                    .foregroundColor(.blue)
                            }
                            
                            if !item.description.isEmpty {
                                Text(item.description)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    // Images
                    if !item.images.isEmpty {
                        let config = ImageViewerConfig(height: 200, cornerRadius: 15, spacing: 8)
                        
                        ImageViewer(config: config) {
                            ForEach(item.images, id: \.self) { imageName in
                                Image(imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .containerValue(\.activeViewID, imageName)
                            }
                        } overlay: {
                            OverlayViewExplore(activeID: nil, item: item)
                        } updates: { isPresented, activeID in
                            // Handle image viewer updates if needed
                        }
                    }
                    
                    // Additional details
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "location")
                                .foregroundColor(.blue)
                            Text(item.location)
                                .font(.body)
                        }
                        
                        HStack {
                            Image(systemName: "tag")
                                .foregroundColor(.blue)
                            Text(item.category)
                                .font(.body)
                        }
                    }
                    .padding(.top)
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    ExploreView()
}
