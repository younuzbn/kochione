//
//  ExploreView.swift
//  Kochi One
//
//  Created by APPLE on 01/10/2025.
//

import SwiftUI
import CoreLocation
import UIKit
import AVKit

// Helper view for loading images from URLs
struct AsyncImageView: View {
    let url: String
    let contentMode: ContentMode
    
    init(url: String, contentMode: ContentMode = .fill) {
        self.url = url
        self.contentMode = contentMode
    }
    
    var body: some View {
        if let imageURL = URL(string: url) {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay {
                            ProgressView()
                        }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        }
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .overlay {
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                }
        }
    }
}

// Helper view for playing videos from URLs
struct VideoPlayerView: View {
    let url: String
    @State private var player: AVPlayer?
    @State private var showPlayButton = true
    
    var body: some View {
        Group {
            if let videoURL = URL(string: url) {
                ZStack {
                    if let player = player {
                        VideoPlayer(player: player)
                            .onAppear {
                                // Don't auto-play in grid view
                                player.pause()
                            }
                            .onDisappear {
                                player.pause()
                            }
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay {
                                VStack {
                                    ProgressView()
                                    Text("Loading video...")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .onAppear {
                                player = AVPlayer(url: videoURL)
                            }
                    }
                    
                    // Play button overlay
                    if showPlayButton {
                        Button {
                            player?.play()
                            showPlayButton = false
                        } label: {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                    }
                }
                .onTapGesture {
                    if let player = player {
                        if player.timeControlStatus == .playing {
                            player.pause()
                            showPlayButton = true
                        } else {
                            player.play()
                            showPlayButton = false
                        }
                    }
                }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay {
                        Image(systemName: "video.slash")
                            .foregroundColor(.gray)
                    }
            }
        }
    }
}

// Media Item View - handles both images and videos
struct MediaItemView: View {
    let mediaItem: MediaItem
    
    var body: some View {
        if mediaItem.type == "video" {
            VideoPlayerView(url: mediaItem.url)
        } else {
            AsyncImageView(url: mediaItem.url, contentMode: .fill)
        }
    }
}

// Reusable Explore Type One View (postType = 1)
struct ExploreTypeOne: View {
    @State private var activeID: String?
    @Binding var showDetail: Bool
    let post: ExplorePost
    @State private var showCallDialog = false
    @State private var showMapPicker = false
    
    private var imageViewerConfig: ImageViewerConfig {
        ImageViewerConfig(height: 100, cornerRadius: 10, spacing: 5)
    }
    
    // Get media items (images and videos) sorted by position
    private var mediaItems: [MediaItem] {
        post.media
            .sorted { $0.position < $1.position }
            .prefix(4)
            .map { $0 }
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(post.title)
                            .font(.headline)
                            .lineLimit(1)
                        
                        Spacer()
                    }
                    
                    // Description
                    Text(post.description)
                        .font(.subheadline)
                        .lineLimit(4)
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                    
                    // Image Viewer with images and videos from API - same design as EatsView (4 items, 2x2 grid)
                    if !mediaItems.isEmpty {
                    ImageViewer(config: imageViewerConfig) {
                            ForEach(mediaItems, id: \.url) { mediaItem in
                                MediaItemView(mediaItem: mediaItem)
                                    .containerValue(\.activeViewID, mediaItem.url)
                        }
                    } overlay: {
                            OverlayViewExplore(activeID: activeID, post: post)
                    } updates: { isPresented, activeID in
                        self.activeID = activeID?.base as? String
                        }
                    }
                    
                    // Action buttons or single button based on contactInfo type (optional)
                    if let contactInfo = post.contactInfo {
                        // Check if button type has data
                        let hasButtonData = contactInfo.type == "button" &&
                            contactInfo.buttonLabel != nil &&
                            !contactInfo.buttonLabel!.isEmpty &&
                            contactInfo.buttonUrl != nil &&
                            !contactInfo.buttonUrl!.isEmpty
                        
                        // Check if contact type has any data
                        let hasContactData = contactInfo.type == "contact" && (
                            (contactInfo.mobile != nil && !contactInfo.mobile!.isEmpty) ||
                            (contactInfo.email != nil && !contactInfo.email!.isEmpty) ||
                            (contactInfo.website != nil && !contactInfo.website!.isEmpty) ||
                            contactInfo.location != nil
                        )
                        
                        if hasButtonData {
                            // Single wide button for button type
                            if let buttonLabel = contactInfo.buttonLabel,
                               let buttonUrl = contactInfo.buttonUrl {
                                Button {
                                    var urlString = buttonUrl
                                    if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
                                        urlString = "https://\(urlString)"
                                    }
                                    if let url = URL(string: urlString) {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    HStack {
                                        if let icon = contactInfo.buttonIcon, !icon.isEmpty {
                                            Image(systemName: icon)
                                        }
                                        Text(buttonLabel)
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                                .padding(.top, 10)
                            }
                        } else if hasContactData {
                            // 4 action buttons (Call, Email, Website, Navigation) for contact type
                            HStack {
                                // 1. Call Button
                                Button {
                                    print("Call button tapped")
                                    showCallDialog = true
                                } label: {
                                    Image(systemName: "phone.fill")
                                }
                                .disabled(contactInfo.mobile == nil || contactInfo.mobile?.isEmpty == true)
                                .confirmationDialog("Call \(post.title)?", isPresented: $showCallDialog, titleVisibility: .visible) {
                                    Button("Call") {
                                        guard let mobile = contactInfo.mobile, !mobile.isEmpty else {
                                            print("Phone number is empty")
                                            return
                                        }
                                        
                                        // Clean phone number: remove spaces, dashes, parentheses, etc., but keep + for international
                                        let cleanedNumber = mobile
                                            .replacingOccurrences(of: " ", with: "")
                                            .replacingOccurrences(of: "-", with: "")
                                            .replacingOccurrences(of: "(", with: "")
                                            .replacingOccurrences(of: ")", with: "")
                                            .replacingOccurrences(of: ".", with: "")
                                        
                                        if let phoneURL = URL(string: "tel://\(cleanedNumber)") {
                                            if UIApplication.shared.canOpenURL(phoneURL) {
                                                UIApplication.shared.open(phoneURL)
                                            } else {
                                                print("Cannot open phone URL: \(phoneURL)")
                                            }
                                        } else {
                                            print("Invalid phone number format: \(cleanedNumber)")
                                        }
                                    }
                                    Button("Cancel", role: .cancel) { }
                                } message: {
                                    Text(contactInfo.mobile?.isEmpty == true ? "No phone number available" : (contactInfo.mobile ?? ""))
                                }
                                
                                Spacer()
                                
                                // 2. Email Button
                                Button {
                                    if let email = contactInfo.email, !email.isEmpty {
                                        if let url = URL(string: "mailto:\(email)") {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                } label: {
                                    Image(systemName: "envelope.fill")
                                }
                                .disabled(contactInfo.email == nil || contactInfo.email?.isEmpty == true)
                                
                                Spacer()
                                
                                // 3. Website Button
                                Button {
                                    if let website = contactInfo.website, !website.isEmpty {
                                        var urlString = website
                                        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
                                            urlString = "https://\(urlString)"
                                        }
                                        if let url = URL(string: urlString) {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                } label: {
                                    Image(systemName: "globe")
                                }
                                .disabled(contactInfo.website == nil || contactInfo.website?.isEmpty == true)
                                
                                Spacer()
                                
                                // 4. Navigation Button
                                Button {
                                    print("Navigation button tapped")
                                    guard let location = contactInfo.location else { return }
                                    
                                    // Show map picker if multiple apps available, otherwise open directly
                                    let availableApps = MapApp.availableApps()
                                    if availableApps.count == 1, let app = availableApps.first {
                                        // Only one app available, open directly
                                        if let url = app.navigationURL(latitude: location.latitude, longitude: location.longitude, businessName: post.title) {
                                            UIApplication.shared.open(url)
                                        }
                                    } else {
                                        // Multiple apps available, show picker
                                        showMapPicker = true
                                    }
                                } label: {
                                    Image(systemName: "location.fill")
                                }
                                .disabled(contactInfo.location == nil)
                                .confirmationDialog("Choose Navigation App", isPresented: $showMapPicker, titleVisibility: .visible) {
                                    if let location = contactInfo.location {
                                        ForEach(MapApp.availableApps()) { app in
                                            Button(app.rawValue) {
                                                if let url = app.navigationURL(latitude: location.latitude, longitude: location.longitude, businessName: post.title) {
                                                    UIApplication.shared.open(url)
                                                }
                                            }
                                        }
                                    }
                                    Button("Cancel", role: .cancel) { }
                                }
                            }
                            .foregroundStyle(.primary.secondary)
                            .padding(.top, 10)
                        }
                    }
                }
                .padding(.top, 10)
            }
            .padding([.leading, .trailing], 15)
            
            Spacer(minLength: 0)
        }
        .contentShape(Rectangle())
    }
}

// Reusable Explore Type Two View (postType = 2)
struct ExploreTypeTwo: View {
    @State private var activeID: String?
    @Binding var showDetail: Bool
    let post: ExplorePost
    @State private var currentMediaIndex: Int = 0
    @Environment(\.colorScheme) var colorScheme
    @State private var showCallDialog = false
    @State private var showMapPicker = false
    
    // Get media items (images and videos) sorted by position
    private var mediaItems: [MediaItem] {
        post.media
            .sorted { $0.position < $1.position }
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(post.title)
                            .font(.headline)
                            .lineLimit(1)
                        
                        Spacer()
                    }
                    
                    // Description
                    Text(post.description)
                        .font(.subheadline)
                        .lineLimit(4)
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                    
                    // Swipeable single media carousel (images and videos)
                    if !mediaItems.isEmpty {
                        TabView(selection: $currentMediaIndex) {
                            ForEach(Array(mediaItems.enumerated()), id: \.element.url) { index, mediaItem in
                                MediaItemView(mediaItem: mediaItem)
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
                    }
                    
                    // Action buttons or single button based on contactInfo type (optional)
                    if let contactInfo = post.contactInfo {
                        // Check if button type has data
                        let hasButtonData = contactInfo.type == "button" &&
                            contactInfo.buttonLabel != nil &&
                            !contactInfo.buttonLabel!.isEmpty &&
                            contactInfo.buttonUrl != nil &&
                            !contactInfo.buttonUrl!.isEmpty
                        
                        // Check if contact type has any data
                        let hasContactData = contactInfo.type == "contact" && (
                            (contactInfo.mobile != nil && !contactInfo.mobile!.isEmpty) ||
                            (contactInfo.email != nil && !contactInfo.email!.isEmpty) ||
                            (contactInfo.website != nil && !contactInfo.website!.isEmpty) ||
                            contactInfo.location != nil
                        )
                        
                        if hasButtonData {
                            // Single wide button for button type
                            if let buttonLabel = contactInfo.buttonLabel,
                               let buttonUrl = contactInfo.buttonUrl {
                                Button {
                                    var urlString = buttonUrl
                                    if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
                                        urlString = "https://\(urlString)"
                                    }
                                    if let url = URL(string: urlString) {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    HStack {
                                        if let icon = contactInfo.buttonIcon, !icon.isEmpty {
                                            Image(systemName: icon)
                                        }
                                        Text(buttonLabel)
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                                .padding(.top, 10)
                            }
                        } else if hasContactData {
                            // 4 action buttons (Call, Email, Website, Navigation) for contact type
                            HStack {
                                // 1. Call Button
                                Button {
                                    print("Call button tapped")
                                    showCallDialog = true
                                } label: {
                                    Image(systemName: "phone.fill")
                                }
                                .disabled(contactInfo.mobile == nil || contactInfo.mobile?.isEmpty == true)
                                .confirmationDialog("Call \(post.title)?", isPresented: $showCallDialog, titleVisibility: .visible) {
                                    Button("Call") {
                                        guard let mobile = contactInfo.mobile, !mobile.isEmpty else {
                                            print("Phone number is empty")
                                            return
                                        }
                                        
                                        // Clean phone number: remove spaces, dashes, parentheses, etc., but keep + for international
                                        let cleanedNumber = mobile
                                            .replacingOccurrences(of: " ", with: "")
                                            .replacingOccurrences(of: "-", with: "")
                                            .replacingOccurrences(of: "(", with: "")
                                            .replacingOccurrences(of: ")", with: "")
                                            .replacingOccurrences(of: ".", with: "")
                                        
                                        if let phoneURL = URL(string: "tel://\(cleanedNumber)") {
                                            if UIApplication.shared.canOpenURL(phoneURL) {
                                                UIApplication.shared.open(phoneURL)
                                            } else {
                                                print("Cannot open phone URL: \(phoneURL)")
                                            }
                                        } else {
                                            print("Invalid phone number format: \(cleanedNumber)")
                                        }
                                    }
                                    Button("Cancel", role: .cancel) { }
                                } message: {
                                    Text(contactInfo.mobile?.isEmpty == true ? "No phone number available" : (contactInfo.mobile ?? ""))
                                }
                                
                                Spacer()
                                
                                // 2. Email Button
                                Button {
                                    if let email = contactInfo.email, !email.isEmpty {
                                        if let url = URL(string: "mailto:\(email)") {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                } label: {
                                    Image(systemName: "envelope.fill")
                                }
                                .disabled(contactInfo.email == nil || contactInfo.email?.isEmpty == true)
                                
                                Spacer()
                                
                                // 3. Website Button
                                Button {
                                    if let website = contactInfo.website, !website.isEmpty {
                                        var urlString = website
                                        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
                                            urlString = "https://\(urlString)"
                                        }
                                        if let url = URL(string: urlString) {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                } label: {
                                    Image(systemName: "globe")
                                }
                                .disabled(contactInfo.website == nil || contactInfo.website?.isEmpty == true)
                                
                                Spacer()
                                
                                // 4. Navigation Button
                                Button {
                                    print("Navigation button tapped")
                                    guard let location = contactInfo.location else { return }
                                    
                                    // Show map picker if multiple apps available, otherwise open directly
                                    let availableApps = MapApp.availableApps()
                                    if availableApps.count == 1, let app = availableApps.first {
                                        // Only one app available, open directly
                                        if let url = app.navigationURL(latitude: location.latitude, longitude: location.longitude, businessName: post.title) {
                                            UIApplication.shared.open(url)
                                        }
                                    } else {
                                        // Multiple apps available, show picker
                                        showMapPicker = true
                                    }
                                } label: {
                                    Image(systemName: "location.fill")
                                }
                                .disabled(contactInfo.location == nil)
                                .confirmationDialog("Choose Navigation App", isPresented: $showMapPicker, titleVisibility: .visible) {
                                    if let location = contactInfo.location {
                                        ForEach(MapApp.availableApps()) { app in
                                            Button(app.rawValue) {
                                                if let url = app.navigationURL(latitude: location.latitude, longitude: location.longitude, businessName: post.title) {
                                                    UIApplication.shared.open(url)
                                                }
                                            }
                                        }
                                    }
                                    Button("Cancel", role: .cancel) { }
                                }
                            }
                            .foregroundStyle(.primary.secondary)
                            .padding(.top, 10)
                        }
                    }
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
    let post: ExplorePost
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
                Text(post.title)
                        .font(.callout)
                        .foregroundStyle(.white)
            }
            
            Spacer(minLength: 0)
        }
        .padding(15)
    }
}

// Main Explore View
struct ExploreView: View {
    @StateObject private var viewModel = ExploreViewModel()
    @State private var showDetail = false
    @State private var selectedPost: ExplorePost?
    
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.posts.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Text("Error loading posts")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Retry") {
                        Task {
                            await viewModel.fetchPosts()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.posts.isEmpty {
                VStack {
                    Text("No posts available")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(viewModel.posts.enumerated()), id: \.element.id) { index, post in
                            // Use postType to determine which view to show
                            if post.postType == 1 {
                                ExploreTypeOne(showDetail: $showDetail, post: post)
                                    .onTapGesture {
                                        selectedPost = post
                                        showDetail = true
                                    }
                            } else if post.postType == 2 {
                                ExploreTypeTwo(showDetail: $showDetail, post: post)
                                    .onTapGesture {
                                        selectedPost = post
                                        showDetail = true
                                    }
                            }
                            
                            // Add a subtle separator between items (not for the last item)
                            if index < viewModel.posts.count - 1 {
                                Divider()
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 15)
                            }
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.fetchPosts()
        }
        .onAppear {
            // Refresh data when view appears to ensure latest data
            Task {
                await viewModel.fetchPosts()
            }
        }
        .refreshable {
            await viewModel.fetchPosts()
        }
        .fullScreenCover(isPresented: $showDetail) {
            if let post = selectedPost {
                ExploreDetailView(post: post) {
                    showDetail = false
                    selectedPost = nil
                }
            }
        }
    }
}

// Detail View for Explore items
struct ExploreDetailView: View {
    let post: ExplorePost
    let onBack: () -> Void
    @State private var showCallDialog = false
    @State private var showMapPicker = false
    
    // Get media items (images and videos) sorted by position
    private var mediaItems: [MediaItem] {
        post.media
            .sorted { $0.position < $1.position }
    }
    
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
                        VStack(alignment: .leading, spacing: 8) {
                        Text(post.title)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                        if !post.description.isEmpty {
                            Text(post.description)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                        }
                    }
                    
                    // Media (Images and Videos)
                    if !mediaItems.isEmpty {
                        let config = ImageViewerConfig(height: 200, cornerRadius: 15, spacing: 8)
                        
                        ImageViewer(config: config) {
                            ForEach(mediaItems, id: \.url) { mediaItem in
                                MediaItemView(mediaItem: mediaItem)
                                    .containerValue(\.activeViewID, mediaItem.url)
                            }
                        } overlay: {
                            OverlayViewExplore(activeID: nil, post: post)
                        } updates: { isPresented, activeID in
                            // Handle image viewer updates if needed
                        }
                    }
                    
                    // Action buttons or single button based on contactInfo type (optional)
                    if let contactInfo = post.contactInfo {
                        // Check if button type has data
                        let hasButtonData = contactInfo.type == "button" &&
                            contactInfo.buttonLabel != nil &&
                            !contactInfo.buttonLabel!.isEmpty &&
                            contactInfo.buttonUrl != nil &&
                            !contactInfo.buttonUrl!.isEmpty
                        
                        // Check if contact type has any data
                        let hasContactData = contactInfo.type == "contact" && (
                            (contactInfo.mobile != nil && !contactInfo.mobile!.isEmpty) ||
                            (contactInfo.email != nil && !contactInfo.email!.isEmpty) ||
                            (contactInfo.website != nil && !contactInfo.website!.isEmpty) ||
                            contactInfo.location != nil
                        )
                        
                        if hasButtonData {
                            // Single wide button for button type
                            if let buttonLabel = contactInfo.buttonLabel,
                               let buttonUrl = contactInfo.buttonUrl {
                                Button {
                                    var urlString = buttonUrl
                                    if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
                                        urlString = "https://\(urlString)"
                                    }
                                    if let url = URL(string: urlString) {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    HStack {
                                        if let icon = contactInfo.buttonIcon, !icon.isEmpty {
                                            Image(systemName: icon)
                                        }
                                        Text(buttonLabel)
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                                .padding(.top)
                            }
                        } else if hasContactData {
                            // 4 action buttons (Call, Email, Website, Navigation) for contact type
                            HStack {
                                // 1. Call Button
                                Button {
                                    print("Call button tapped")
                                    showCallDialog = true
                                } label: {
                                    Image(systemName: "phone.fill")
                                }
                                .disabled(contactInfo.mobile == nil || contactInfo.mobile?.isEmpty == true)
                                .confirmationDialog("Call \(post.title)?", isPresented: $showCallDialog, titleVisibility: .visible) {
                                    Button("Call") {
                                        guard let mobile = contactInfo.mobile, !mobile.isEmpty else {
                                            print("Phone number is empty")
                                            return
                                        }
                                        
                                        // Clean phone number: remove spaces, dashes, parentheses, etc., but keep + for international
                                        let cleanedNumber = mobile
                                            .replacingOccurrences(of: " ", with: "")
                                            .replacingOccurrences(of: "-", with: "")
                                            .replacingOccurrences(of: "(", with: "")
                                            .replacingOccurrences(of: ")", with: "")
                                            .replacingOccurrences(of: ".", with: "")
                                        
                                        if let phoneURL = URL(string: "tel://\(cleanedNumber)") {
                                            if UIApplication.shared.canOpenURL(phoneURL) {
                                                UIApplication.shared.open(phoneURL)
                                            } else {
                                                print("Cannot open phone URL: \(phoneURL)")
                                            }
                                        } else {
                                            print("Invalid phone number format: \(cleanedNumber)")
                                        }
                                    }
                                    Button("Cancel", role: .cancel) { }
                                } message: {
                                    Text(contactInfo.mobile?.isEmpty == true ? "No phone number available" : (contactInfo.mobile ?? ""))
                                }
                                
                                Spacer()
                                
                                // 2. Email Button
                                Button {
                                    if let email = contactInfo.email, !email.isEmpty {
                                        if let url = URL(string: "mailto:\(email)") {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                } label: {
                                    Image(systemName: "envelope.fill")
                                }
                                .disabled(contactInfo.email == nil || contactInfo.email?.isEmpty == true)
                                
                                Spacer()
                                
                                // 3. Website Button
                                Button {
                                    if let website = contactInfo.website, !website.isEmpty {
                                        var urlString = website
                                        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
                                            urlString = "https://\(urlString)"
                                        }
                                        if let url = URL(string: urlString) {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                } label: {
                                    Image(systemName: "globe")
                                }
                                .disabled(contactInfo.website == nil || contactInfo.website?.isEmpty == true)
                                
                                Spacer()
                                
                                // 4. Navigation Button
                                Button {
                                    print("Navigation button tapped")
                                    guard let location = contactInfo.location else { return }
                                    
                                    // Show map picker if multiple apps available, otherwise open directly
                                    let availableApps = MapApp.availableApps()
                                    if availableApps.count == 1, let app = availableApps.first {
                                        // Only one app available, open directly
                                        if let url = app.navigationURL(latitude: location.latitude, longitude: location.longitude, businessName: post.title) {
                                            UIApplication.shared.open(url)
                                        }
                                    } else {
                                        // Multiple apps available, show picker
                                        showMapPicker = true
                                    }
                                } label: {
                                    Image(systemName: "location.fill")
                                }
                                .disabled(contactInfo.location == nil)
                                .confirmationDialog("Choose Navigation App", isPresented: $showMapPicker, titleVisibility: .visible) {
                                    if let location = contactInfo.location {
                                        ForEach(MapApp.availableApps()) { app in
                                            Button(app.rawValue) {
                                                if let url = app.navigationURL(latitude: location.latitude, longitude: location.longitude, businessName: post.title) {
                                                    UIApplication.shared.open(url)
                                                }
                                            }
                                        }
                                    }
                                    Button("Cancel", role: .cancel) { }
                                }
                            }
                            .foregroundStyle(.primary.secondary)
                            .padding(.top)
                        }
                    }
                    
                    // Additional details
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "eye.fill")
                                .foregroundColor(.blue)
                            Text("\(post.views) views")
                                .font(.body)
                        }
                        
                        if let contactInfo = post.contactInfo, let location = contactInfo.location {
                        HStack {
                                Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                                Text("\(String(format: "%.4f", location.latitude)), \(String(format: "%.4f", location.longitude))")
                                .font(.body)
                            }
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
