//
//  ImageCacheService.swift
//  Kochi One
//
//  Created by APPLE on 01/10/2025.
//

import SwiftUI
import Foundation

class ImageCacheService {
    static let shared = ImageCacheService()
    
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 100 // Limit cache to 100 images
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB limit
    }
    
    func getImage(from url: String) -> UIImage? {
        return cache.object(forKey: url as NSString)
    }
    
    func setImage(_ image: UIImage, for url: String) {
        cache.setObject(image, forKey: url as NSString)
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}

// Custom AsyncImage that uses caching
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: String
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    private let imageCache = ImageCacheService.shared
    @State private var image: UIImage?
    @State private var isLoading = true
    
    init(url: String, @ViewBuilder content: @escaping (Image) -> Content, @ViewBuilder placeholder: @escaping () -> Placeholder) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = image {
                content(Image(uiImage: image))
            } else if isLoading {
                placeholder()
            } else {
                placeholder()
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        // Check cache first
        if let cachedImage = imageCache.getImage(from: url) {
            self.image = cachedImage
            self.isLoading = false
            return
        }
        
        // Load from network
        guard let imageURL = URL(string: url) else {
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let data = data, let downloadedImage = UIImage(data: data) {
                    self.image = downloadedImage
                    self.imageCache.setImage(downloadedImage, for: url)
                }
            }
        }.resume()
    }
}
